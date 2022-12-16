in some cases, the client network will cause mtu mismatch

possible reasons may be vpn, tunnel, firewall or other network configuration in the network path

when this problem occurs, the mtu of client's wg0 interface need to be adjusted

for example, the client use wireguard as this:

```shell
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

then just run `docker restart wireguard`

and the mtu of interface wg0 will adjust automatically

if the automatically adjusting does not work or wireguard is not used through docker

use `ifconfig <Interface_name> mtu <mtu_size> up` to change mtu manually

for example, `ifconfig wg0 mtu 1392 up`

use `ping <wg0_gateway> -M do -s <number_of_data_bytes>` to find a proper mtu size

and don't forget that changes of mtu using `ifconfig <Interface_name> mtu <mtu_size> up` will be reset after a reboot
