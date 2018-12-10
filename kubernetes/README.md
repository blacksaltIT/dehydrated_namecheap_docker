# Kubernetes deployment

> Warning: Never copy-paste commands without careful review what will they do!

This example assumes:
1. you preinstalled `kubectl` in the image
1. you use [haproxy-ingress](https://github.com/jcmoraisjr/haproxy-ingress) as an ingress controller
1. you use `ingress-controller` namespace

## 1) preinstall kubectl example
The example refers to `bscustom` tag which already contains the binary.
```
FROM blacksalt/dehydrated_namecheap:latest

# kubectl
ARG KUBECTL_VERSION=v1.12.2
RUN curl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl > /usr/bin/kubectl && \
    chmod -v +x /usr/bin/kubectl && \
    kubectl version --client
```

## 2) haproxy-ingress
Follow the description of deploying haproxy-ingress. Don't forget to tell haproxy to use your cert: `--default-ssl-certificate=$(POD_NAMESPACE)/dehydrated-namecheap-cert`

