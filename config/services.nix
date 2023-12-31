# List services that you want to enable:
let
  localDomain = "lan.mejora.dev";
  dnsRecords = [
    {
      domain = "*.lan.mejora.dev";
      answer = "192.168.178.2";
    }
  ];
in
{
  services = {
    openssh = {
      enable = true;
      ports = [ 2022 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        AllowGroups = [ "ssh-users" ];
      };
    };
    kea = {
      dhcp4 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = [
              "enp2s0"
            ];
            service-sockets-max-retries = 10;
            service-sockets-retry-wait-time = 5000;
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          valid-lifetime = 4000;
          rebind-timer = 2000;
          renew-timer = 1000;
          subnet4 = [
            {
              id = 1;
              pools = [
                {
                  pool = "192.168.178.50 - 192.168.178.99";
                }
              ];
              subnet = "192.168.178.0/24";
            }
          ];
          option-data = [
            {
              name = "routers";
              code = 3;
              space = "dhcp4";
              csv-format = true;
              data = "192.168.178.1";
            }
            {
              name = "domain-name-servers";
              code = 6;
              space = "dhcp4";
              csv-format = true;
              data = "192.168.178.2";
            }
            {
              name = "domain-name";
              code = 15;
              space = "dhcp4";
              data = localDomain;
            }
          ];
        };
      };
    };
    samba = {
      enable = true;
      openFirewall = true;
      shares = {
        files = {
          path = "/data/personal/share";
          "read only" = false;
          browseable = "yes";
          "guest ok" = "no";
          comment = "Share for documents";
        };
        media = {
          path = "/data/media/storage/organized";
          "read only" = true;
          browseable = "yes";
          "guest ok" = "no";
          comment = "Share for media";
        };
        scans = {
          path = "/data/personal/scans";
          "read only" = false;
          browseable = "yes";
          "guest ok" = "no";
          comment = "Share for network scanner";
        };
      };
    };
    adguardhome = {
      enable = true;
      openFirewall = true;
      settings = {
        dns = {
          upstream_dns = [ "1.1.1.1" ];
          rewrites = dnsRecords;
        };
      };
    };
    # printing.enable = true;
  };
}

