# List services that you want to enable:
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
              data = "192.168.178.1";
            }
            {
              name = "domain-name";
              code = 15;
              space = "dhcp4";
              data = "lan.mejora.dev";
            }
          ];
        };
      };
    };
#    k3s = {
#      enable = true;
#      role = "server";
#      extraFlags = toString[
##        "--kubelet-arg=v=4" # verbosity level
#        "--cluster-cidr=10.42.0.0/16"
#        "--service-cidr=10.43.0.0/16"
#        "--flannel-backend=none"
#        "--disable-kube-proxy"
#        "--disable-network-policy"
#      ];
#    };
    samba = {
      enable = true;
      openFirewall = true;
      shares = {

      };
    };
    # printing.enable = true;
  };
}
