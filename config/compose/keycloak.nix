{ pkgs, settings, ... }:

{
  compose = (pkgs.formats.yaml { }).generate "keycloak.yaml" {
    name = "keycloak";
    services = {
      keycloak = {
        container_name = "keycloak";
        depends_on = [ "postgres" ];
        command = [ "start" "--https-certificate-file=/opt/keycloak/data/certs/sso.${settings.domain}.crt" "--https-certificate-key-file=/opt/keycloak/data/certs/sso.${settings.domain}.key" "--hostname=sso.${settings.domain}" ];
        environment = {
          KC_DB = "postgres";
          KC_DB_PASSWORD = "\${POSTGRES_PWD}";
          KC_DB_URL = "jdbc:postgresql://postgres:5432/keycloak";
          KC_DB_USERNAME = "\${POSTGRES_USER}";
          KC_LOG_LEVEL = "\${KC_LOG_LEVEL}";
          KC_METRICS_ENABLED = true;
          KEYCLOAK_ADMIN = "\${KEYCLOAK_ADMIN}";
          KEYCLOAK_ADMIN_PASSWORD = "\${KEYCLOAK_ADMIN_PASSWORD}";
        };
        image = "quay.io/keycloak/keycloak:24.0";
        networks = [ "traefik" ];
        ports = [ "8443:8443" ];
        restart = "unless-stopped";
        user = "10009";
        volumes = [ "/home/keycloak/letsencrypt/certificates:/opt/keycloak/data/certs" ];
      };
      postgres = {
        environment = {
          POSTGRES_DB = "keycloak";
          POSTGRES_PASSWORD = "\${POSTGRES_PWD}";
          POSTGRES_USER = "\${POSTGRES_USER}";
        };
        healthcheck = {
          test = [ "CMD" "pg_isready" "-U" "keycloak" ];
        };
        image = "postgres:15.5-alpine";
        networks = [ "traefik" ];
        restart = "unless-stopped";
        volumes = [ "/home/keycloak/db:/var/lib/postgresql/data" ];
      };
    };
    networks = {
      traefik = {
        external = true;
      };
    };
    version = "2.4";
  };
}
