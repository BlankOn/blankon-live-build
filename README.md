# BlankOn live-build

This repository contains the BlankOn live-build configuration. ISO build
orchestration lives in the separate
[blankon-live-builder](https://github.com/BlankOn/blankon-live-builder)
repository.

The Debian Live project produces the framework used to build live systems based on Debian and the official Debian Live images themselves.

References:
* [Wiki Debian Live Build](https://wiki.debian.org/DebianLive)
* [Debian Live Build](https://www.debian.org/devel/debian-live/)
* [Debian Live Build Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)

## Prerequisites and preparation

### Install tools:
```
sudo apt install debootstrap live-build make git apt-utils
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
- Create file `/usr/share/debootstrap/scripts/sinambung` with this content
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
  (no need symlink if you're using docker for building images)
  ```
  sudo ln -s /usr/share/live/build/data/debian-cd/squeeze /usr/share/live/build/data/debian-cd/sinambung
  ```
## Build

Build through the standalone
[blankon-live-builder](https://github.com/BlankOn/blankon-live-builder)
wrapper. The builder repository owns `build-iso` and its `.env` file. The
live-build checkout is mounted at `/source`; the builder checkout is mounted at
`/builder`.

Prepare the builder configuration:

```
git clone https://github.com/BlankOn/blankon-live-builder.git
cd blankon-live-builder
cp .env.example .env
# Edit .env with the build and publishing settings.
```

From the Kang Jahit workdir, a local build merges `config/common/` with the
directory named by `variant` (for example, `config/gnome/`) into `.build/config/`
before calling live-build.

```
/builder/build-iso --local /source
```

The Docker worker can build a committed branch instead:

```
/builder/build-iso --remote <repo> <branch> [commit]
```

## TODO

Notification to blankon-dev mailing list (need SMTP server).
