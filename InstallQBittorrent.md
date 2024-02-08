# note

use official image: https://github.com/qbittorrent/docker-qbittorrent-nox

# enable bbr tcp congestion control

```
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
```
# deprecated

## install method 1: docker

edit ./Dockerfile

```Dockerfile
FROM ubuntu
ENV LANG C.UTF-8
RUN apt update \
    && apt upgrade -y \
    && apt install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x401e8827da4e93e44c7d01e6d35164147ca69fc4" | gpg --dearmor -o /etc/apt/keyrings/qbittorrent.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/qbittorrent.gpg] https://ppa.launchpadcontent.net/qbittorrent-team/qbittorrent-stable/ubuntu $(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d = -f 2) main" | tee /etc/apt/sources.list.d/qbittorrent.list > /dev/null \
    && apt update \
    && apt install -y qbittorrent-nox\
    && rm -rf /var/lib/apt/lists/*
ARG UNAME=qbittorrent-nox
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $UNAME \
    && useradd -u $UID -g $GID -m -s /usr/sbin/nologin $UNAME
USER $UNAME
RUN mkdir -p /home/$UNAME/.config/qBittorrent/ \
    && printf "[LegalNotice]\nAccepted=true\n" > /home/$UNAME/.config/qBittorrent/qBittorrent.conf
ENTRYPOINT ["qbittorrent-nox"]
```

note: creating and editing /home/$UNAME/.config/qBittorrent/qBittorrent.conf is useless.
the purpose of this step is to make qbittorrent skip 'Legal Notice' when using docker option -it.
when docker option -it is not used, qbittorrent will skip 'Legal Notice' automatically.

build

```
docker build -t qbittorrent-nox .
```

run

```
mkdir /srv/qbittorrent-nox
chown 1000:1000 /srv/qbittorrent-nox
docker run -d \
    -v /srv/qbittorrent-nox:/home/qbittorrent-nox \
    --network host \
    --restart always \
    --name qbittorrent-nox \
    qbittorrent-nox
```

## install method 2

install qbittorrent

```
add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
apt update
apt install qbittorrent-nox
```

add user and group

```
adduser --system --group qbittorrent-nox
```

edit /etc/systemd/system/qbittorrent-nox.service

```
[Unit]
Description=qBittorrent-nox
After=network.target

[Service]
Type=forking
User=qbittorrent-nox
Group=qbittorrent-nox
UMask=022
ExecStart=/usr/bin/qbittorrent-nox -d

[Install]
WantedBy=multi-user.target
```

enable and start service

```
systemctl daemon-reload
systemctl enable qbittorrent-nox
systemctl start qbittorrent-nox
```
