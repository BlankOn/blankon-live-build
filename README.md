# BlankOn live-build

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
