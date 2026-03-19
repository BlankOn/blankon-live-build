# BlankOn live-build

This is repository for BlankOn live-build configuration. Before migrated to live-build, Blankon used to build the ISOs using custom-made script called [pabrik-cc](https://github.com/BlankOn/pabrik-cc) based on old debootstrap.

The Debian Live project produces the framework used to build live systems based on Debian and the official Debian Live images themselves.

References:
* [Wiki Debian Live Build](https://wiki.debian.org/DebianLive)
* [Debian Live Build](https://www.debian.org/devel/debian-live/)
* [Debian Live Build Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)

## Prerequisites

- Docker
- Docker Compose

## Setup

1. Clone repo
   ```
   git clone https://github.com/BlankOn/blankon-live-build.git
   cd blankon-live-build
   ```

2. Copy and fill in the environment file
   ```
   cp .env.example .env
   ```

   | Variable | Description |
   |---|---|
   | `TELEGRAM_BOT_KEY` | Telegram bot token for build notifications |
   | `HOST_JAHITAN_PATH` | Host directory where ISO output will be stored |
   | `BUILD_PUBLISH_URL` | Public URL where ISOs are served |
   | `BUILD_JAHITAN_PATH` | Path inside the container for ISO output (default: `/jahitan`) |
   | `BUILD_LOCKFILE` | Lockfile path inside the container (default: `/tmp/blankon-build.lock`) |

3. Create the jahitan output directory on the host
   ```
   mkdir -p /your/jahitan/path
   ```

## Build

`build-iso` automatically manages the Docker container — no manual Docker setup needed.

**Production build** (pulls config from a git branch):
```
./build-iso <repo-url> <branch> [commit]
```

**Local build** (uses the `config/` and `auto/` in this repo):
```
./build-iso
```

Build artifacts (chroot, cache, tmp) stay inside the container. ISO output is written to `HOST_JAHITAN_PATH` on the host.

## TODO

Notification to blankon-dev mailing list (need SMTP server).
