#!/usr/bin/env bash
if [ ! -f /home/keycloak/letsencrypt/certificates/sso.lan.mejora.dev.crt ]; then
  echo "requesting new certificate"
  LEGO_ARG='-a --email "acme@mejora.dev" --dns transip --domains "sso.lan.mejora.dev" --path /letsencrypt run' \
  /run/current-system/sw/bin/docker compose -f /etc/nixos/resources/docker-compose/lego.yml up
else
  echo "checking certificate renewal"
  LEGO_ARG='-a --email "acme@mejora.dev" --dns transip --domains "sso.lan.mejora.dev" --path /letsencrypt renew --days 5' \
  /run/current-system/sw/bin/docker compose -f /etc/nixos/resources/docker-compose/lego.yml up
fi