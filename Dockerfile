FROM alpine:3.8
ARG PREINSTALLED_PACKAGES=
RUN apk add --no-cache git bash openssl bind-tools curl ${PREINSTALLED_PACKAGES}

# dehydrated + namecheap hook
ARG DEHYDRATED_GIT_REPO=https://github.com/lukas2511/dehydrated.git
ARG DEHYDRATED_GIT_REF=master
ARG DEHYDRATED_NAMECHEAP_GIT_REPO=https://github.com/wdouglascampbell/dehydrated_namecheap_dns_api_hook.git
ARG DEHYDRATED_NAMECHEAP_GIT_REF=master
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
RUN echo 'source <(for v in $(compgen -v | grep ^DHV_); do echo "${v//DHV_}=$(eval "echo -n \"\$${v}\"")"; done)' > /app/config

# Dehydrated NameCheap hook configuration
# Set variables as described in https://github.com/wdouglascampbell/dehydrated_namecheap_dns_api_hook/blob/master/config
# but prefix them with DHNV_
ENV DHNV_DEPLOYED_CERTDIR=/app_data/certs \
    DHNV_DEPLOYED_KEYDIR=/app_data/keys
RUN echo 'source <(for v in $(compgen -v | grep ^DHNV_); do echo "${v//DHNV_}=$(eval "echo -n \"\$${v}\"")"; done)' > /app/dehydrated_namecheap_dns_api_hook/config

ENV RELOAD_SCRIPT=/app_files/reload_services.sh
RUN echo 'bash "$RELOAD_SCRIPT" "$@"' >> /app/dehydrated_namecheap_dns_api_hook/reload_services.sh

VOLUME /app_data/
VOLUME /app_files/

CMD [ "/bin/bash", "-c", "(mkdir -pv $DHV_BASEDIR $DHNV_DEPLOYED_CERTDIR $DHNV_DEPLOYED_KEYDIR; ((source <(/app/dehydrated --env); test -f $ACCOUNT_KEY) || /app/dehydrated --register --accept-terms) && /app/dehydrated --cron) & trap \"kill -INT $!\" INT TERM; wait %1" ]
