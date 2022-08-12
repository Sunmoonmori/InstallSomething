# create docker network

```
docker network create -d bridge prometheus_grafana
```

# run grafana

the cert and key of our host's domain name are placed at `/home/ubuntu/.cert/`

we mark our cert and key as \<our cert\> and \<our key\>

our host's domain name will be used to access grafana, we mark it as \<domain name\>

```
docker run \
    -d \
    -p 3000:3000 \
    -e "GF_SERVER_PROTOCOL=https" \
    -e "GF_SERVER_CERT_FILE=/.cert/<our cert>" \
    -e "GF_SERVER_CERT_KEY=/.cert/<our key>" \
    -v /home/ubuntu/.cert:/.cert \
    --network prometheus_grafana \
    --name grafana \
    --restart always \
    grafana/grafana-enterprise
```

# run node_exporter

node_exporter is placed at `/home/ubuntu/node_exporter-1.4.0-rc.0.linux-amd64/node_exporter`

the user to run node_exporter is `ubuntu`

node_exporter.service

```
[Unit]
Description=node_exporter
Wants=network-online.target
After=network-online.target

[Service]
User=ubuntu
Group=ubuntu
Type=simple
ExecStart=/home/ubuntu/node_exporter-1.4.0-rc.0.linux-amd64/node_exporter --collector.systemd --collector.processes

[Install]
WantedBy=multi-user.target
```

place it at `/etc/systemd/system` and then enable and run this service

# run prometheus

prometheus.yml

```
global:
  scrape_interval: 15s

scrape_configs:
- job_name: node
  static_configs:
  - targets: ['<domain name>:9100']
```

the targets in `prometheus.yml` must use a domain name or ip address which can be accessed from inside the container, and thus something like `localhost` will not work

since node_exporter is run on host, we use `<domain name>:9100` to access

`prometheus.yml` is placed at `/home/ubuntu/prometheus.yml`

```
docker run \
    -d \
    -v /home/ubuntu/prometheus.yml:/etc/prometheus/prometheus.yml \
    --network prometheus_grafana \
    --name prometheus \
    --restart always \
    prom/prometheus
```

generally, `-p 9090:9090` should be used to expose port 9090 to host's port 9090

but we won't expose it because our prometheus should only be used by grafana, and they are in the same container network `prometheus_grafana`

# configure grafana datasource and dashboard

get container ip in container network `prometheus_grafana`

```
docker network inspect prometheus_grafana
```

here 172.18.0.2 is grafana container ip, and 172.18.0.3 is prometheus container ip

\<domain name\> is the domain name of our host, see above

go to https://\<domain name\>:3000/datasources to add datasource

we must use http://172.18.0.3:9090 here for prometheus datasource

this is because the port of our prometheus is not exposed and should be accessed from inside the container network `prometheus_grafana`

go to https://\<domain name\>:3000/dashboards to import dashboard

we can get one from https://grafana.com/grafana/dashboards/, for example, ID 1860

the parameters of our node_exporter (`--collector.systemd` and `--collector.processes`) are for the dashboard ID 1860

# block other access to node_exporter

172.18.0.3 is prometheus container ip got in previous step

9100 is the port of node_exporter

```
sudo iptables -t filter -A INPUT -p tcp -s 172.18.0.3 --dport 9100 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 9100 -j DROP
```
