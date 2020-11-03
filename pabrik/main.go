package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/adeven/redismq"
)

var queue *redismq.Queue

type Trigger struct {
	ID         string `json:"id"`
	Repository string `json:"repository"`
	Branch     string `json:"branch"`
	Commit     string `json:"commit"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "POST":
		var t Trigger
		err := json.NewDecoder(r.Body).Decode(&t)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		jsonByte, err := json.Marshal(t)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		queue.Put(string(jsonByte))
		w.Write([]byte("OK"))

	default:
		fmt.Fprintf(w, "Antrian pabrik ISO.")
	}
}

func main() {
	queue = redismq.CreateQueue("localhost", "6379", "", 9, "live-build-queue")

	consumer, err := queue.AddConsumer("live-build-worker")
	if err != nil {
		log.Fatal(err)
	}

	go func() {
		for {
			time.Sleep(time.Second * 1)
			q, err := consumer.Get()
			if err != nil && !strings.Contains(err.Error(), "unacked") {
				log.Println(err)
				continue
			}
			if q == nil {
				continue
			}

			log.Println(q)

			var t Trigger
			err = json.Unmarshal([]byte(q.Payload), &t)
			if err != nil {
				log.Println(err)
				continue
			}
			output, err := exec.Command("./build.sh", t.Repository, t.Branch, t.Commit).Output()
			if err != nil {
				log.Println(err)
				continue
			}
			log.Println(output)

			err = q.Ack()
			if err != nil {
				log.Println(err)
				continue
			}

		}
	}()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handler(w, r)
	})
	port := os.Getenv("PORT")
	if len(port) < 1 {
		port = "8000"
	}
	fmt.Printf("Starting tendang at port " + port + "\n")
	// Listen only for requests from localhost
	if err := http.ListenAndServe("127.0.0.1:"+port, nil); err != nil {
		log.Fatal(err)
	}
}
