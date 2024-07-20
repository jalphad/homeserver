{ pkgs, settings, ... }:

{
  compose = (pkgs.formats.yaml { }).generate "keycloak.yaml" {
    networks = {
      traefik = {
        external = true;
      };
    };
    services = {
      broker = {
        image = "docker.io/library/redis:7";
        networks = [ "traefik" ];
        restart = "unless-stopped";
        volumes = [ "redisdata:/data" ];
      };
      db = {
        environment = {
          POSTGRES_DB = "paperless";
          POSTGRES_PASSWORD = "paperless";
          POSTGRES_USER = "paperless";
        };
        image = "docker.io/library/postgres:15";
        networks = [ "traefik" ];
        restart = "unless-stopped";
        volumes = [ "pgdata:/var/lib/postgresql/data" ];
      };
      gotenberg = {
        command = [
          "gotenberg"
          "--chromium-disable-javascript=true"
          "--chromium-allow-list=file:///tmp/.*"
        ];
        image = "docker.io/gotenberg/gotenberg:7.10";
        networks = [ "traefik" ];
        restart = "unless-stopped";
      };
      tika = {
        image = "ghcr.io/paperless-ngx/tika:latest";
        networks = [ "traefik" ];
        restart = "unless-stopped";
      };
      webserver = {
        depends_on = [
          "db"
          "broker"
          "gotenberg"
          "tika"
        ];
        env_file = "paperless.env";
        environment = {
          USERMAP_UID = "10005";
          PAPERLESS_OCR_LANGUAGES = "eng nld";
          PAPERLESS_URL = "https://paperless.${settings.domain}";
          PAPERLESS_TIME_ZONE = settings.timezone;
          USERMAP_GID = "10004";
          PAPERLESS_DBHOST = "db";
          PAPERLESS_REDIS = "redis://broker:6379";
          PAPERLESS_TIKA_ENABLED = 1;
          PAPERLESS_TIKA_ENDPOINT = "http://tika:9998";
          PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://gotenberg:3000";
        };
        healthcheck = {
          interval = "30s";
          retries = 5;
          test = [ "CMD" "curl" "-fs" "-S" "--max-time" "2" "http://localhost:8000" ];
          timeout = "10s";
        };
        image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
        labels = [
          "traefik.enable=true"
          "traefik.http.services.paperless.loadbalancer.server.port=8000"
          "traefik.http.routers.paperless.rule=Host(`paperless.${settings.domain}`)"
          "traefik.http.routers.paperless.entrypoints=websecure"
          "traefik.http.routers.paperless.tls.certresolver=mydnschallenge"
        ];
        networks = [ "traefik" ];
        restart = "unless-stopped";
        volumes = [
          "/data/personal/paperless-ngx/d:/usr/src/paperless/data"
          "/data/personal/paperless-ngx/m:/usr/src/paperless/media"
          "/data/personal/paperless-ngx/export:/usr/src/paperless/export"
          "/data/personal/scans:/usr/src/paperless/consume"
        ];
      };
    };
    version = "3.4";
  };
}
