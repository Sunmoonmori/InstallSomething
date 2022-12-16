# note

config files will be saved and loaded at host path /srv/wireguard/configs through volume mount

take care of the environment viriables of server

remember to replace SERVERURL value

# server

```
docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -e SERVERURL=example.com \
  -e SERVERPORT=51820 \
  -e PEERS=3 \
  -e PEERDNS=auto \
  -e INTERNAL_SUBNET=10.13.13.0 \
  -e ALLOWEDIPS=10.13.13.0/24 \
  -e LOG_CONFS=false \
  -p 51820:51820/udp \
  -v /srv/wireguard/config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart always \
  lscr.io/linuxserver/wireguard:latest
```

# client

```
docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  --network host \
  -v /srv/wireguard/config:/config \
  -v /lib/modules:/lib/modules \
  --restart always \
  lscr.io/linuxserver/wireguard:latest
```
