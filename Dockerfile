FROM alpine:3.8
ARG PREINSTALLED_PACKAGES=
RUN apk add --no-cache git bash openssl bind-tools curl ${PREINSTALLED_PACKAGES}

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
# Set environment variables as described in https://github.com/lukas2511/dehydrated/blob/master/docs/examples/config
# but prefix them with DHV_
ENV DHV_BASEDIR=/app_data \
    DHV_HOOK=/app/dehydrated_namecheap_dns_api_hook/namecheap_dns_api_hook.sh
RUN echo "eval \"\$(declare -xp | sed -n 's/^declare -x DHV_//p')\"" > /app/config

# Dehydrated NameCheap hook configuration
# Set environment variables as described in https://github.com/wdouglascampbell/dehydrated_namecheap_dns_api_hook/blob/master/config
# but prefix them with DHNV_
ENV DHNV_DEPLOYED_CERTDIR=/app_data/deployed_certs \
    DHNV_DEPLOYED_KEYDIR=/app_data/deployed_keys
RUN echo "eval \"\$(declare -xp | sed -n 's/^declare -x DHNV_//p')\"" > /app/dehydrated_namecheap_dns_api_hook/config

ENV DEPLOY_COMMANDS=
RUN echo "eval \"\$DEPLOY_COMMANDS\"" >> /app/dehydrated_namecheap_dns_api_hook/reload_services.sh

VOLUME /app/app_data

CMD [ "/bin/bash", "-lc", "((source <(/app/dehydrated --env); test -f $ACCOUNT_KEY) || /app/dehydrated --register --accept-terms) && /app/dehydrated --cron" ]
