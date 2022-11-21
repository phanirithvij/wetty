#!/usr/bin/env bash
# https://hub.docker.com/r/cirocosta/alpine-envsubst/dockerfile
apk add gettext libintl
envsubst '$${NGINX_DOMAIN},$${NGINX_PORT},$${WETTY_HOST},$${WETTY_PORT},$${REDIS_HOST},$${REDIS_PORT}' < \
/etc/nginx/conf.d/wetty.template > /etc/nginx/conf.d/default.conf
apk del gettext libintl
