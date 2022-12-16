_nodeport is not as recommanded as ingress_

# another method: do not use ingress but use nodeport

## use default port udp 51820

1. enable node port

    note: should only edit the file once

    ```shell
    echo "--service-node-port-range=0-65535" >> /var/snap/microk8s/current/args/kube-apiserver
    microk8s stop
    microk8s start
    ```

2. update service using type nodeport

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: wireguard
    spec:
      type: NodePort
      selector:
        app: wireguard
      ports:
      - port: 51820
        protocol: UDP
        nodePort: 51820
    ```

## or: use another port

no need to enable additional node port

don't forget to change the env in ConfigMap and corresponding ports in Deployment and Service
