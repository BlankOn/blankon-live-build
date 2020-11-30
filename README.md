# BlankOn live-build

This is repository for BlankOn live-build configuration. Before migrated to live-build, Blankon used to build the ISOs using custom-made script called [pabrik-cc](https://github.com/BlankOn/pabrik-cc) based on old debootstrap.

The Debian Live project produces the framework used to build live systems based on Debian and the official Debian Live images themselves.

References:
* [Wiki Debian Live Build](https://wiki.debian.org/DebianLive)
* [Debian Live Build](https://www.debian.org/devel/debian-live/)
* [Debian Live Build Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)

## Prerequisites and preparation

Need live-build version **20191222** or commit sha on `7360d50fa6b`

### Install tools:
```
sudo apt install debootstrap make git
git clone https://salsa.debian.org/live-team/live-build.git debian-live-build
cd debian-live-build
git checkout 7360d50fa6b
sudo make install
sudo lb --version
```

### Clone Repo and Preparation

- Clone repo
  ```
  git clone https://github.com/BlankOn/blankon-live-build.git
  ```
- Install blankon-keyring
  ```
  cd blankon-live-build
  sudo dpkg -i config/packages/blankon-keyring_2020.10.29-1.0_all.deb
  ```
- Create file `/usr/share/debootstrap/scripts/verbeek` with this content
  ```
  mirror_style release
  download_style apt
  finddebs_style from-indices
  variants - buildd fakechroot minbase
  keyring /usr/share/keyrings/blankon-archive-keyring.gpg

  # include common settings
  if [ -e "$DEBOOTSTRAP_DIR/scripts/debian-common" ]; then
   . "$DEBOOTSTRAP_DIR/scripts/debian-common"
  elif [ -e /debootstrap/debian-common ]; then
   . /debootstrap/debian-common
  elif [ -e "$DEBOOTSTRAP_DIR/debian-common" ]; then
   . "$DEBOOTSTRAP_DIR/debian-common"
  else
   error 1 NOCOMMON "File not found: debian-common"
  fi
  ```
- Create symlink in host files to satisfy udeb packages (?) [see this issue](https://github.com/BlankOn/Verbeek/issues/134). 
  (no need symlink if using docker for building images)
  ```
  sudo ln -s /usr/share/live/build/data/debian-cd/squeeze /usr/share/live/build/data/debian-cd/verbeek
  ```
## Build

- `sudo lb clean --purge`
- `sudo lb config`
- `sudo lb build`

There is `build.sh` script that could be used to export the result to BlankOn's jahitan-harian directory.

Simple way
```
bash build.sh
```

## Using Docker for build
**On host:** 
- `docker build -t blankon-live-build:verbeek .`
- `docker run --rm -ti --cap-add sys_admin -v $(pwd):/src blankon-live-build:verbeek bash`
**Inside docker container:** 
- `lb clean`
- `lb config`
- `lb build`


## Troubleshooting
- ```
  P: Begin installing local package lists...
  E: You need to install apt-utils on your host system.
  E: An unexpected failure occurred, exiting...
  P: Begin unmounting filesystems...
  ```
  Solution: `apt install apt-utils` inside your host or docker container

## TODO

Notification to blankon-dev mailing list (need SMTP server).
