{pkgs,settings,...}:

let 
  freeradius = import ./compose/freeradius.nix {pkgs=pkgs;settings=settings;};
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