# Pabrik

Simple queue service for live-build.

### Usage

```
 curl --header "Content-Type: application/json" --request POST --data '{"id":"pipeline-id-xyz123","repository":"https://github.com/BlankOn/blankon-live-build.git", "branch": "master"}' http://localhost:8000
```
