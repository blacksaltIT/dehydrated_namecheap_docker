FROM blacksalt/dehydrated_namecheap:latest

# kubectl
ARG KUBECTL_VERSION=v1.12.2
RUN curl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl > /usr/bin/kubectl && \
    chmod -v +x /usr/bin/kubectl && \
    kubectl version --client
