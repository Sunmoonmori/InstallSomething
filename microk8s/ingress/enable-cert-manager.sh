#!/bin/bash

microk8s enable cert-manager

# # this step follows the prompt of `microk8s enable cert-manager`
# # this step may fails because not everything is configured and running properly, just wait and rerun
# # remember to replace me@example.com with your email, see comments below
# microk8s kubectl apply -f - <<EOF
# ---
# apiVersion: cert-manager.io/v1
# kind: ClusterIssuer
# metadata:
#   name: letsencrypt
# spec:
#   acme:
#     # You must replace this email address with your own.
#     # Let's Encrypt will use this to contact you about expiring
#     # certificates, and issues related to your account.
#     email: me@example.com
#     server: https://acme-v02.api.letsencrypt.org/directory
#     privateKeySecretRef:
#       # Secret resource that will be used to store the account's private key.
#       name: letsencrypt-account-key
#     # Add a single challenge solver, HTTP01 using nginx
#     solvers:
#     - http01:
#         ingress:
#           class: public
# EOF

# # test
# # remember to replace example.com with your external domain name
# microk8s kubectl create deploy --image cdkbot/microbot:1 --replicas 3 microbot
# microk8s kubectl expose deploy microbot --port 80 --type ClusterIP
# microk8s kubectl apply -f - <<EOF
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: microbot-ingress
#   annotations:
#     cert-manager.io/cluster-issuer: letsencrypt
# spec:
#   tls:
#   - hosts:
#     - example.com
#     secretName: microbot-ingress-tls
#   rules:
#   - host: example.com
#     http:
#       paths:
#       - backend:
#           service:
#             name: microbot
#             port:
#               number: 80
#         path: /
#         pathType: Exact
# EOF