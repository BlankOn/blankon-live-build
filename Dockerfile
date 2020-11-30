# base image debian 10
FROM debian:buster

LABEL MAINTAINER artemtech <sofyanartem@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y debootstrap make git cpio curl && \
git clone https://salsa.debian.org/live-team/live-build.git /tmp/debian-live-build && \
cd /tmp/debian-live-build && \
git checkout 7360d50fa6b && \
make install && \
cd /root && rm -rf /tmp/debian-live-build && \
lb --version

# download earlier blankon keyring (because newest version is broken)
#RUN curl -o /tmp/blankon-keyring.deb http://arsip-dev.blankonlinux.or.id/dev/pool/main/b/blankon-keyring/blankon-keyring_2020.10.29-1.0_all.deb && \
RUN curl -o /tmp/blankon-keyring.deb https://github.com/BlankOn/blankon-live-build/blob/61ab74e89b4a71671e7cdb8fbf219f5d0a04a4cb/config/packages/blankon-keyring_2020.10.29-1.0_all.deb?raw=true && \
dpkg -i /tmp/blankon-keyring.deb && rm /tmp/blankon-keyring.deb

RUN echo 'mirror_style release \n\
download_style apt \n\
finddebs_style from-indices \n\
variants - buildd fakechroot minbase \n\
keyring /usr/share/keyrings/blankon-archive-keyring.gpg \n\

# include common settings \n\
if [ -e "$DEBOOTSTRAP_DIR/scripts/debian-common" ]; then \n\
 . "$DEBOOTSTRAP_DIR/scripts/debian-common" \n\
elif [ -e /debootstrap/debian-common ]; then \n\
 . /debootstrap/debian-common \n\
elif [ -e "$DEBOOTSTRAP_DIR/debian-common" ]; then \n\
 . "$DEBOOTSTRAP_DIR/debian-common" \n\
else \n\
 error 1 NOCOMMON "File not found: debian-common" \n\
fi \n' >> /usr/share/debootstrap/scripts/verbeek

# see https://github.com/BlankOn/Verbeek/issues/134
RUN ln -s /usr/share/live/build/data/debian-cd/squeeze /usr/share/live/build/data/debian-cd/verbeek

WORKDIR /src

VOLUME /src

CMD ["bash"]
