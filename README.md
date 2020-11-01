# BlankOn live-build

This is repository for BlankOn live-build configuration. Before migrated to live-build, Blankon used to build the ISOs using custom-made script called [pabrik-cc](https://github.com/BlankOn/pabrik-cc) based on old debootstrap.

The Debian Live project produces the framework used to build live systems based on Debian and the official Debian Live images themselves.

References:
* [Wiki Debian Live Build](https://wiki.debian.org/DebianLive)
* [Debian Live Build](https://www.debian.org/devel/debian-live/)
* [Debian Live Build Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)

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
