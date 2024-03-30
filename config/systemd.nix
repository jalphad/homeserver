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
    };
    timers = {
      ssocert = {
        timerConfig = {
          OnCalendar = "21:09";
          RandomizedDelaySec = "1h";
          AccuracySec = "2h";
        };
      };
    };
  };
}