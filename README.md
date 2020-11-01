# BlankOn live-build

BlankOn Live Build is script repository for build BlankOn Images base on Debian Live project. Before using this tool, Blankon use custom-made call [pabrik-cc](https://github.com/BlankOn/pabrik-cc) base on old debootstrap.
The Debian Live project produces the framework used to build live systems based on Debian and the official Debian Live images themselves.

References:
* [Wiki Debian Live Buind](https://wiki.debian.org/DebianLive)
* [Debian Live Build](https://www.debian.org/devel/debian-live/)

## Prerequisites and preparation

- `blankon-keyring` package installed
- The latest live-build package (https://github.com/BlankOn/live-build/blob/master/build_master.zip) installed
- Copy `/usr/share/debootstrap/scripts/stretch` to `/usr/share/debootstrap/scripts/verbeek`
- In `/usr/share/debootstrap/scripts/verbeek`, change the `debian-archive-keyring` string to `blankon-archive-keyring`

## Build

- `sudo lb clean --purge`
- `sudo lb config`
- `sudo lb build`

There is `build.sh` script that could be used to export the result to BlankOn's jahitan-harian directory.

## TODO

Notification to blankon-dev mailing list (need SMTP server).
