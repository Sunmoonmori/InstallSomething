#!/bin/bash

microk8s kubectl patch daemonset.apps/nginx-ingress-microk8s-controller -n ingress --patch-file wireguard-patch-nginx-ingress-microk8s-controller.yaml
microk8s kubectl patch configmap/nginx-ingress-udp-microk8s-conf -n ingress --patch-file wireguard-patch-nginx-ingress-udp-microk8s-conf.yaml
