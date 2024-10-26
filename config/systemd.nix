{config, pkgs,settings,...}:

let 
  freeradius = import ./compose/freeradius.nix {inherit pkgs settings;};
  media = import ./compose/media.nix {inherit pkgs settings;};
  unifi = import ./compose/unifi.nix {inherit pkgs settings;};
  keycloak = import ./compose/keycloak.nix {inherit pkgs settings;};
  paperless = import ./compose/paperless.nix {inherit pkgs settings;};
in
{
  systemd = {
    services = {
      ssocert = {
        unitConfig = {
          Description = "Request SSO Certificate for Keycloak";
          After = "docker.service network-online.target";
          Requires = "network-online.target";
        };
        serviceConfig = {
          Environment="PATH=/run/current-system/sw/bin";
          RemainAfterExit = "true";
          Type = "oneshot";
          TimeoutStartSec = "0";
          WorkingDirectory = "/home/keycloak";
          ExecStartPre = [
            "-/run/current-system/sw/bin/docker compose -f /etc/nixos/resources/docker-compose/lego.yml down -v"
            "-/run/current-system/sw/bin/docker compose -f /etc/nixos/resources/docker-compose/lego.yml rm -v"
            "-/run/current-system/sw/bin/docker compose -f /etc/nixos/resources/docker-compose/lego.yml pull"
          ];
          ExecStart = "/etc/nixos/resources/scripts/ssocert.sh";
          ExecStop = "/run/current-system/sw/bin/docker compose -f /etc/nixos/resources/docker-compose/lego.yml down -v";
        };
        wantedBy = [ "multi-user.target" ];
      };
      freeradius = {
        unitConfig = {
          Description = "Run freeradius in Docker container";
          After = "docker.service network-online.target";
          Requires = "network-online.target";
        };
        serviceConfig = {
          Environment="PATH=/run/current-system/sw/bin";
          RemainAfterExit = "true";
          Type = "simple";
          TimeoutStartSec = "0";
          WorkingDirectory = "/home/radius";
          ExecStartPre = [
            "-/run/current-system/sw/bin/docker compose -f ${freeradius.compose} down -v"
            "-/run/current-system/sw/bin/docker compose -f ${freeradius.compose} rm -v"
            "-/run/current-system/sw/bin/docker compose -f ${freeradius.compose} pull"
          ];
          ExecStart = "/run/current-system/sw/bin/docker compose -f ${freeradius.compose} up -d";
          ExecStop = "/run/current-system/sw/bin/docker compose -f ${freeradius.compose} down -v";
        };
        wantedBy = [ "multi-user.target" ];
      };
      media = {
        unitConfig = {
          Description = "Run media services in Docker";
          After = "docker.service network-online.target";
          Requires = "network-online.target";
        };
        serviceConfig = {
          Environment="PATH=/run/current-system/sw/bin";
          RemainAfterExit = "true";
          Type = "simple";
          TimeoutStartSec = "0";
          WorkingDirectory = "/data/media/mediamgmt";
          ExecStartPre = [
            "-/run/current-system/sw/bin/docker compose -f ${media.compose} down -v"
            "-/run/current-system/sw/bin/docker compose -f ${media.compose} rm -v"
            "-/run/current-system/sw/bin/docker compose -f ${media.compose} pull"
          ];
          ExecStart = "/run/current-system/sw/bin/docker compose -f ${media.compose} up -d";
          ExecStop = "/run/current-system/sw/bin/docker compose -f ${media.compose} down -v";
        };
        wantedBy = [ "multi-user.target" ];
      };
      unifi = {
        unitConfig = {
          Description = "Run Unifi in Docker";
          After = "docker.service network-online.target";
          Requires = "network-online.target";
        };
        serviceConfig = {
          Environment="PATH=/run/current-system/sw/bin";
          RemainAfterExit = "true";
          Type = "simple";
          TimeoutStartSec = "0";
          WorkingDirectory = "/home/unifi";
          ExecStartPre = [
            "-/run/current-system/sw/bin/docker compose -f ${unifi.compose} down -v"
            "-/run/current-system/sw/bin/docker compose -f ${unifi.compose} rm -v"
            "-/run/current-system/sw/bin/docker compose -f ${unifi.compose} pull"
          ];
          ExecStart = "/run/current-system/sw/bin/docker compose -f ${unifi.compose} up -d";
          ExecStop = "/run/current-system/sw/bin/docker compose -f ${unifi.compose} down -v";
        };
        wantedBy = [ "multi-user.target" ];
      };
      keycloak = {
        unitConfig = {
          Description = "Run Keycloak in Docker";
          After = "docker.service network-online.target";
          Requires = "network-online.target";
        };
        serviceConfig = {
          Environment="PATH=/run/current-system/sw/bin";
          RemainAfterExit = "true";
          Type = "simple";
          TimeoutStartSec = "0";
          WorkingDirectory = "/home/keycloak";
          ExecStartPre = [
            "-/run/current-system/sw/bin/docker compose -f ${keycloak.compose} down -v"
            "-/run/current-system/sw/bin/docker compose -f ${keycloak.compose} rm -v"
            "-/run/current-system/sw/bin/docker compose -f ${keycloak.compose} pull"
          ];
          ExecStart = "/run/current-system/sw/bin/docker compose -f ${keycloak.compose} --env-file ${config.sops.secrets."keycloak.env".path} up -d";
          ExecStop = "/run/current-system/sw/bin/docker compose -f ${keycloak.compose} down -v";
        };
        wantedBy = [ "multi-user.target" ];
      };
      paperless = {
        unitConfig = {
          Description = "Run Paperless in Docker";
          After = "docker.service network-online.target";
          Requires = "network-online.target";
        };
        serviceConfig = {
          Environment="PATH=/run/current-system/sw/bin";
          RemainAfterExit = "true";
          Type = "simple";
          TimeoutStartSec = "0";
          ExecStartPre = [
            "-/run/current-system/sw/bin/docker compose -f ${paperless.compose} down -v"
            "-/run/current-system/sw/bin/docker compose -f ${paperless.compose} rm -v"
            "-/run/current-system/sw/bin/docker compose -f ${paperless.compose} pull"
          ];
          ExecStart = "/run/current-system/sw/bin/docker compose -f ${paperless.compose} --env-file ${config.sops.secrets."paperless.env".path} up -d";
          ExecStop = "/run/current-system/sw/bin/docker compose -f ${paperless.compose} down -v";
        };
        wantedBy = [ "multi-user.target" ];
      };
    };
    timers = {
      ssocert = {
        enable = true;
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "1h";
          Persistent = "true";
        };
      };
    };
  };
}