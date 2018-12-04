FROM alpine:3.8
ARG PREINSTALLED_PACKAGES=
RUN apk add --no-cache git bash openssl bind-tools curl ${PREINSTALLED_PACKAGES}

# kubectl
ARG KUBECTL_VERSION=v1.12.2
RUN curl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl > /usr/bin/kubectl && \
    chmod -v +x /usr/bin/kubectl && \
    kubectl version --client

# dehydrated + namecheap hook
ARG DEHYDRATED_GIT_REPO=https://github.com/lukas2511/dehydrated.git
ARG DEHYDRATED_GIT_REF=master
ARG DEHYDRATED_NAMECHEAP_GIT_REPO=https://github.com/blacksaltIT/dehydrated_namecheap_dns_api_hook.git
ARG DEHYDRATED_NAMECHEAP_GIT_REF=remotes/origin/curl_opts
RUN git clone ${DEHYDRATED_GIT_REPO} /app/ && \
    git -C /app reset --hard ${DEHYDRATED_GIT_REF} && \
    git clone ${DEHYDRATED_NAMECHEAP_GIT_REPO} /app/dehydrated_namecheap_dns_api_hook && \
    git -C /app/dehydrated_namecheap_dns_api_hook reset --hard ${DEHYDRATED_NAMECHEAP_GIT_REF} && \
    rm -rfv /app/.git /app/dehydrated_namecheap_dns_api_hook/.git

# Dehydrated configuration
# Set variables as described in https://github.com/lukas2511/dehydrated/blob/master/docs/examples/config
# but prefix them with DHV_
ENV DHV_BASEDIR=/app_data/dehydrated \
    DHV_HOOK=/app/dehydrated_namecheap_dns_api_hook/namecheap_dns_api_hook.sh
RUN echo "source <(declare -xp | sed -n 's/^declare -x DHV_//p')" > /app/config

# Dehydrated NameCheap hook configuration
# Set variables as described in https://github.com/wdouglascampbell/dehydrated_namecheap_dns_api_hook/blob/master/config
# but prefix them with DHNV_
ENV DHNV_DEPLOYED_CERTDIR=/app_data/certs \
    DHNV_DEPLOYED_KEYDIR=/app_data/keys
RUN echo "source <(declare -xp | sed -n 's/^declare -x DHNV_//p')" > /app/dehydrated_namecheap_dns_api_hook/config

ENV DEPLOY_COMMANDS=
RUN echo "source <(echo \"\$DEPLOY_COMMANDS\")" >> /app/dehydrated_namecheap_dns_api_hook/reload_services.sh

VOLUME /app_data/

CMD [ "/bin/bash", "-c", "(mkdir -pv $DHV_BASEDIR $DHNV_DEPLOYED_CERTDIR $DHNV_DEPLOYED_KEYDIR; ((source <(/app/dehydrated --env); test -f $ACCOUNT_KEY) || /app/dehydrated --register --accept-terms) && /app/dehydrated --cron) & trap \"kill -INT $!\" INT TERM; wait %1" ]
