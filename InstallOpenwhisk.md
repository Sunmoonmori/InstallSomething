proxy may be needed anywhere

1. install nfs server
    ```
    sudo apt update
    sudo apt install nfs-kernel-server
    sudo mkdir /var/nfs/kubedata -p
    sudo chown nobody: /var/nfs/kubedata
    sudo systemctl enable nfs-server.service
    sudo systemctl start nfs-server.service
    ```
    add this line to `/etc/exports`
    ```
    /var/nfs/kubedata * (rw,sync,no_subtree_check,no_root_squash,no_all_squash)
    ```
    apply
    ```
    sudo exportfs -rav
    ```
2. install nfs-subdir-external-provisioner
    ```
    helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
    helm install nfs-subdir-external-provisioner  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
        --set nfs.server=localhost \
        --set nfs.path=/var/nfs/kubedata
    ```
3. edit mycluster.yaml
    ```
    whisk:
      ingress:
        type: NodePort
        apiHostName: localhost
        apiHostPort: 31001
    nginx:
      httpsNodePort: 31001
    invoker:
      containerFactory:
        impl: "kubernetes"
    k8s:
      persistence:
        hasDefaultStorageClass: false
        explicitStorageClass: nfs-client

    # single node
    affinity:
      enabled: false
    toleration:
      enabled: false
    invoker:
      options: "-Dwhisk.kubernetes.user-pod-node-affinity.enabled=false"
    ```
4. label node, this is an example for single node cluster
    ```
    kubectl label nodes --all openwhisk-role=invoker
    ```
4. install openwhisk
    ```
    git clone https://github.com/apache/openwhisk-deploy-kube.git
    helm install owdev ./helm/openwhisk -n openwhisk --create-namespace -f  mycluster.yaml
    kubectl get pods -n openwhisk --watch
    ```