#!/bin/bash

echo "--allowed-unsafe-sysctls 'net.ipv4.conf.all.src_valid_mark,net.ipv4.ip_forward'" >> /var/snap/microk8s/current/args/kubelet
microk8s stop
microk8s start
