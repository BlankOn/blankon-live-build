FROM ghcr.io/blankon/blankon-nightly:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    live-build=1:20250814 \
    debootstrap \
    git \
    apt-utils \
    blankon-keyring \
    zsync \
    curl \
    jq \
    ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN cat <<'EOF' > /usr/share/debootstrap/scripts/verbeek
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
EOF

WORKDIR /build

CMD ["/bin/bash"]
