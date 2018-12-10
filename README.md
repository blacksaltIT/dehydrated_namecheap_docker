# Dehydrated-NameCheap docker image

This image uses [dehydrated](https://github.com/lukas2511/dehydrated) and [dehydrated_namecheap_dns_api_hook](https://github.com/wdouglascampbell/dehydrated_namecheap_dns_api_hook) to request one or more certificates from Let's Encrypt.

You can run it either as
- a pure docker container executed by a cronjob
- a Kubernetes CronJob (see kubernetes folder for an example)

## Build arguments

| Name | Description | Default |
|--|--|--|
| PREINSTALLED_PACKAGES | This list will be passed to `apk add` | |
| DEHYDRATED_GIT_REPO | Dehydrated git repo url | https://github.com/lukas2511/dehydrated.git |
| DEHYDRATED_GIT_REF | This arg will be passed to `git reset --hard` after clone | master |
| DEHYDRATED_NAMECHEAP_GIT_REPO | Dehydrated namecheap git repo url | https://github.com/wdouglascampbell/dehydrated_namecheap_dns_api_hook.git |
| DEHYDRATED_NAMECHEAP_GIT_REF | This arg will be passed to `git reset --hard` after clone | master |

## Environment variables

| Name | Description | Default |
|--|--|--|
| RELOAD_SCRIPT | Path of the [reload script](https://github.com/wdouglascampbell/dehydrated_namecheap_dns_api_hook/blob/master/reload_services.sh). No `x` permission necessary. | /app_files/reload_services.sh |
| DHV_* | Prefix will be stripped and variable will be passed to dehydrated. See the variable list [here](https://github.com/lukas2511/dehydrated/blob/master/docs/examples/config) | |
| DHNV_* | Prefix will be stripped and variable will be passed to dehydrated namecheap hook. See the variable list [here](https://github.com/wdouglascampbell/dehydrated_namecheap_dns_api_hook/blob/master/config) | |

You can refer to other variables in values just like in the example config files. In this case use the prefixed variable name.

## Volumes

| Name | Description
|--|--|
| /app_data/ | Mount volume for generated files here |
| /app_files/ | Mount user supplied files here such as reload script or domains.txt |

These mount points are just recommendations, but if you want to change them then be aware to adjust `DHV_BASEDIR`, `DHNV_DEPLOYED_CERTDIR`, `DHNV_DEPLOYED_KEYDIR` and `RELOAD_SCRIPT` too.

