#!/usr/bin/env bash
if [ ! -f /home/keycloak/certs/sso.lan.mejora.dev.key ]; then
  LEGO_ARG='--email "you@example.com" --dns cloudflare --domains "sso.lan.mejora.dev" run' \
  /run/current-system/sw/bin/docker compose -f /etc/nixos/resources/docker-compose/lego.yml up
else
  LEGO_ARG='--email "you@example.com" --dns cloudflare --domains "sso.lan.mejora.dev" renew --days 5' \
  /run/current-system/sw/bin/docker compose -f /etc/nixos/resources/docker-compose/lego.yml up
fi