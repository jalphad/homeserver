{ pkgs, settings, ... }:

with pkgs;
rec {
  jellyfinConfig = writeTextFile {
    name = "config.json";
    text = ''
      {
        "includeCorsCredentials": false,
        "multiserver": false,
        "themes": [
          {
            "name": "Apple TV",
            "id": "appletv",
            "color": "#bcbcbc"
          }, {
            "name": "Blue Radiance",
            "id": "blueradiance",
            "color": "#011432"
          }, {
            "name": "Dark",
            "id": "dark",
            "color": "#202020",
            "default": true
          }, {
            "name": "Light",
            "id": "light",
            "color": "#303030"
          }, {
            "name": "Purple Haze",
            "id": "purplehaze",
            "color": "#000420"
          }, {
            "name": "WMC",
            "id": "wmc",
            "color": "#0c2450"
          }
        ],
        "menuLinks": [
          {
            "name": "What to watch",
            "url": "https://jellyseerr.${settings.domain}"
          }
        ],
        "servers": [],
        "plugins": [
          "playAccessValidation/plugin",
          "experimentalWarnings/plugin",
          "htmlAudioPlayer/plugin",
          "htmlVideoPlayer/plugin",
          "photoPlayer/plugin",
          "comicsPlayer/plugin",
          "bookPlayer/plugin",
          "youtubePlayer/plugin",
          "backdropScreensaver/plugin",
          "pdfPlayer/plugin",
          "logoScreensaver/plugin",
          "sessionPlayer/plugin",
          "chromecastPlayer/plugin"
        ]
      }
    '';
    destination = "/config.json";
  };
  compose = {
    name = "media";
    services = {
      jellyfin = {
        container_name = "jellyfin";
        devices = [
          "/dev/dri/renderD128:/dev/dri/renderD128"
          "/dev/dri/card0:/dev/dri/card0"
        ];
        environment = [
          "JELLYFIN_PublishedServerUrl=https://jellyfin.${settings.domain}"
        ];
        group_add = [ "26" "303" ];
        image = "jellyfin/jellyfin";
        labels = [
          "traefik.enable=true"
          "traefik.http.routers.jellyfin.entryPoints=websecure"
          "traefik.http.routers.jellyfin.rule=Host(`jellyfin.${settings.domain}`)"
          "traefik.http.routers.jellyfin.tls=true"
          "traefik.http.routers.jellyfin.tls.certResolver=mydnsresolver"
          "traefik.http.routers.jellyfin.tls.domains=jellyfin.${settings.domain}"
          "traefik.http.routers.jellyfin.middlewares=jellyfin-mw"
          "traefik.http.middlewares.jellyfin-mw.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex"
          "traefik.http.middlewares.jellyfin-mw.headers.SSLRedirect=true"
          "traefik.http.middlewares.jellyfin-mw.headers.SSLHost=jellyfin.${settings.domain}"
          "traefik.http.middlewares.jellyfin-mw.headers.SSLForceHost=true"
          "traefik.http.middlewares.jellyfin-mw.headers.STSSeconds=315360000"
          "traefik.http.middlewares.jellyfin-mw.headers.STSIncludeSubdomains=true"
          "traefik.http.middlewares.jellyfin-mw.headers.STSPreload=true"
          "traefik.http.middlewares.jellyfin-mw.headers.forceSTSHeader=true"
          "traefik.http.middlewares.jellyfin-mw.headers.contentTypeNosniff=true"
          "traefik.http.middlewares.jellyfin-mw.headers.customresponseheaders.X-XSS-PROTECTION=0"
          "traefik.http.routers.jellyfin.service=jellyfin-svc@file"
          "traefik.http.services.jellyfin-svc.loadBalancer.server.port=8096"
          "traefik.http.services.jellyfin-svc.loadBalancer.passHostHeader=true"
        ];
        network_mode = "host";
        restart = "unless-stopped";
        user = "10008:10003";
        volumes = [
          "/data/media/mediamgmt/jellyfin/config:/config"
          "/data/media/mediamgmt/jellyfin/cache:/cache"
          "/data/media/storage/organized:/media"
          "${jellyfinConfig}/config.json:/jellyfin/jellyfin-web/config.json"
        ];
      };
      jellyseerr = {
        container_name = "jellyseerr";
        environment = [
          "LOG_LEVEL=info"
          "TZ=${settings.timezone}"
        ];
        image = "fallenbagel/jellyseerr:preview-OIDC";
        labels = [
          "traefik.enable=true"
          "traefik.http.services.jellyseerr.loadbalancer.server.port=5055"
          "traefik.http.routers.jellyseerr.rule=Host(`jellyseerr.${settings.domain}`)"
          "traefik.http.routers.jellyseerr.entrypoints=websecure"
          "traefik.http.routers.jellyseerr.tls.certresolver=mydnschallenge"
        ];
        networks = [ "traefik" ];
        restart = "unless-stopped";
        user = "10008:10003";
        volumes = [
          "/data/media/mediamgmt/jellyseerr:/app/config"
        ];
      };
      prowlarr = {
        container_name = "prowlarr";
        environment = [
          "PUID=10008"
          "PGID=10003"
          "TZ=${settings.timezone}"
        ];
        image = "lscr.io/linuxserver/prowlarr:latest";
        labels = [
          "traefik.enable=true"
          "traefik.http.services.prowlarr.loadbalancer.server.port=9696"
          "traefik.http.routers.prowlarr.rule=Host(`prowlarr.${settings.domain}`)"
          "traefik.http.routers.prowlarr.entrypoints=websecure"
          "traefik.http.routers.prowlarr.tls.certresolver=mydnschallenge"
        ];
        networks = [ "traefik" ];
        restart = "unless-stopped";
        volumes = [
          "/data/media/mediamgmt/prowlarr:/config"
        ];
      };
      qbittorrent = {
        container_name = "qbittorrent";
        environment = [
          "PUID=10008"
          "PGID=10003"
          "TZ=${settings.timezone}"
          "WEBUI_PORT=8080"
        ];
        image = "lscr.io/linuxserver/qbittorrent:latest";
        labels = [
          "traefik.enable=true"
          "traefik.http.services.torrent.loadbalancer.server.port=8080"
          "traefik.http.routers.torrent.rule=Host(`torrent.${settings.domain}`)"
          "traefik.http.routers.torrent.entrypoints=websecure"
          "traefik.http.routers.torrent.tls.certresolver=mydnschallenge"
        ];
        networks = [ "traefik" ];
        ports = [
          "6881:6881"
          "6881:6881/udp"
        ];
        restart = "unless-stopped";
        volumes = [
          "/data/media/mediamgmt/qbittorrent:/config"
          "/data/media:/media"
        ];
      };
      radarr = {
        container_name = "radarr";
        environment = [
          "PUID=10008"
          "PGID=10003"
          "TZ=${settings.timezone}"
        ];
        image = "lscr.io/linuxserver/radarr:latest";
        labels = [
          "traefik.enable=true"
          "traefik.http.services.radarr.loadbalancer.server.port=7878"
          "traefik.http.routers.radarr.rule=Host(`radarr.${settings.domain}`)"
          "traefik.http.routers.radarr.entrypoints=websecure"
          "traefik.http.routers.radarr.tls.certresolver=mydnschallenge"
        ];
        networks = [ "traefik" ];
        restart = "unless-stopped";
        volumes = [
          "/data/media/mediamgmt/radarr:/config"
          "/data/media:/media"
        ];
      };
      sonarr = {
        container_name = "sonarr";
        environment = [
          "PUID=10008"
          "PGID=10003"
          "TZ=${settings.timezone}"
        ];
        image = "lscr.io/linuxserver/sonarr:latest";
        labels = [
          "traefik.enable=true"
          "traefik.http.services.sonarr.loadbalancer.server.port=8989"
          "traefik.http.routers.sonarr.rule=Host(`sonarr.${settings.domain}`)"
          "traefik.http.routers.sonarr.entrypoints=websecure"
          "traefik.http.routers.sonarr.tls.certresolver=mydnschallenge"
        ];
        networks = [ "traefik" ];
        restart = "unless-stopped";
        volumes = [
          "/data/media/mediamgmt/sonarr:/config"
          "/data/media:/media"
        ];
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
