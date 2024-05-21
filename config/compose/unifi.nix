{ pkgs, settings, ... }:

with pkgs;
{
  compose = (formats.yaml { }).generate "unifi.yaml" {
    name = "unifi";
    services = {
      unifi-db = {
        container_name = "unifi-db";
        image = "docker.io/mongo:4.4.26";
        networks = [ "traefik" ];
        restart = "unless-stopped";
        user = "10004";
        volumes = [
          "/home/unifi/db/data:/data/db"
          "/home/unifi/db/init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js:ro"
        ];
      };
      unifi-network-application = {
        container_name = "unifi-network-application";
        environment = [
          "PUID=10004"
          "PGID=100"
          "TZ=${settings.timezone}"
          "MONGO_USER=unifi"
          "MONGO_PASS=Welcome123$"
          "MONGO_HOST=unifi-db"
          "MONGO_PORT=27017"
          "MONGO_DBNAME=unifi"
          "MEM_LIMIT=256"
          "MEM_STARTUP=256"
        ];
        image = "lscr.io/linuxserver/unifi-network-application:latest";
        labels = [
          "traefik.enable=true"
          "traefik.http.services.unifi.loadbalancer.server.port=8443"
          "traefik.http.services.unifi.loadbalancer.server.scheme=https"
          "traefik.http.services.unifi.loadbalancer.serverstransport=unifiui@file"
          "traefik.http.serverstransports.unifitransport.insecureSkipVerify=true"
          "traefik.http.routers.unifi.rule=Host(`unifi.${settings.domain}`)"
          "traefik.http.routers.unifi.entrypoints=websecure"
          "traefik.http.routers.unifi.tls.certresolver=mydnschallenge"
        ];
        networks = [ "traefik" ];
        ports = [
          "3478:3478/udp"
          "10001:10001/udp"
          "8080:8080"
        ];
        restart = "unless-stopped";
        volumes = [ "/home/unifi/unifi-app:/config" ];
      };
    };
    networks = {
      traefik = { external = true; };
    };
    version = "2.4";
  };
}
