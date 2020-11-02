# BlankOn live-build

BlankOn Live Build is script repository for build BlankOn Images base on Debian Live project. Before using this tool, Blankon use custom-made call [pabrik-cc](https://github.com/BlankOn/pabrik-cc) base on old debootstrap.
The Debian Live project produces the framework used to build live systems based on Debian and the official Debian Live images themselves.

References:
* [Wiki Debian Live Buind](https://wiki.debian.org/DebianLive)
* [Debian Live Build](https://www.debian.org/devel/debian-live/)

## Prerequisites and preparation

Need live-build version **20191222**

### Install tools:
```
sudo apt install debootstrap make git
git clone https://salsa.debian.org/live-team/live-build.git debian-live-build
cd debian-live-build
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

## Build

- `sudo lb clean --purge`
- `sudo lb config`
- `sudo lb build`

There is `build.sh` script that could be used to export the result to BlankOn's jahitan-harian directory.

Simple way
```
bash build.sh
```

## TODO

Notification to blankon-dev mailing list (need SMTP server).
