_ref: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/_

0. check if values below are unique:
    1. MAC address:
        ```
        ifconfig
        ```
    2. product_uuid:
        ```
        sudo cat /sys/class/dmi/id/product_uuid
        ```
1. disable swap:
    1. check: 
        ```
        sudo swapon --show
        ```
    2. disable:
        ```
        sudo swapoff -a
        sudo rm /swap.img
        ```
    3. remove line from `/etc/fstab`:
        ```
        /swap.img       none    swap    sw      0       0
        ```
2. check `br_netfilter` module:
    ```
    lsmod | grep br_netfilter
    ```
    load it if not:
    ```
    sudo modprobe br_netfilter
    ```
    then config values:
    ```
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
    br_netfilter
    EOF

    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOF
    sudo sysctl --system
    ```
3. install runtime (docker)
    ```
    sudo apt-get update
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    ```

    then edit docker cgroup driver:
    ```
    cat <<EOF | sudo tee -a /etc/docker/daemon.json
    {
        "exec-opts": ["native.cgroupdriver=systemd"]
    }
    EOF
    sudo systemctl restart docker
    ```
4. install `kubeadm`, `kubelet` and `kubectl` (both methods in official documentation need proxy)

    install using tuna.tsinghua mirror:

    1. the first two and the last steps are the same as the official documentation
        ```
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl
        ```
    2. this step need proxy, considering copy file:
        ```
        sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
        ```
    3. only the url is different from the official documentation:
        ```
        echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        ```
    4. install and start services using apt, `apt-mark hold` is necessary: 
        ```
        sudo apt-get update
        sudo apt-get install kubelet kubeadm kubectl
        sudo apt-mark hold kubelet kubeadm kubectl
        ```
5. initialize control plane without any consideration about high available (for example, multi-control-plane and loadbalancer) using aliyun mirrors:
    ```
    sudo kubeadm init --image-repository registry.aliyuncs.com/google_containers
    ```
    if flannel will be used as the pod network add-on, `--pod-network-cidr=10.244.0.0/16` shoud be added:
    ```
    sudo kubeadm init --image-repository registry.aliyuncs.com/google_containers --pod-network-cidr=10.244.0.0/16
    ```
    if high available is taken into consideration, more attention should be paid on `--control-plane-endpoint` 
6. since this step, some commands follow the message shown together with the success info. configure kubectl:
    ```
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```
7. install a pod network add-on. this is a neccessary step. since there are too many choices, no  certain instruction is provided. see https://kubernetes.io/docs/concepts/cluster-administration/addons/ and https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model

    there is an example for flannel. this step need proxy, considering copy file:
    ```
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    ```

    check the result. wait until flannel and coredns is running:
    ```
    kubectl get pods --all-namespaces
    ```
8. if scheduling pods on the control plane node is needed:
    ```
    kubectl taint nodes --all node-role.kubernetes.io/master-
    ```
9. install dashboard. this step need proxy, considering copy file:
    ```
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
    ```
    access by channel to k8s cluster at localhost:
    ```
    kubectl proxy
    ```
    or from outside:
    ```
    kubectl proxy --address='0.0.0.0'  --accept-hosts='^*$'
    ```
10. install helm:
    ```
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    ```
11. join worker nodes:
    ```
    kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
    ```
    show values needed:
    ```
    kubeadm token list
    openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
        openssl dgst -sha256 -hex | sed 's/^.* //'
    ```
    or generate new token:
    ```
    kubeadm token create
    ```
12. clean up control plane:
    ```
    kubeadm reset
    ```
    remove node:
    ```
    kubectl drain <node name> --delete-emptydir-data --force --ignore-daemonsets
    kubeadm reset
    iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
    ipvsadm -C
    kubectl delete node <node name>
    ```