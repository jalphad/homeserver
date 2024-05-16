{pkgs,settings,self,...}:

# List services that you want to enable:
let
  hashFn = import ../helpers/pwhash.nix {pkgs=pkgs;};
  ldapSuffixFn = import ../helpers/ldapsuffix.nix {lib=pkgs.lib;};
  ldapSuffix = ldapSuffixFn settings.domain;
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
                  pool = settings.services.dhcp.pool;
                }
              ];
              subnet = settings.services.dhcp.subnet;
            }
          ];
          option-data = [
            {
              name = "routers";
              code = 3;
              space = "dhcp4";
              csv-format = true;
              data = settings.services.dhcp.routers;
            }
            {
              name = "domain-name-servers";
              code = 6;
              space = "dhcp4";
              csv-format = true;
              data = settings.services.dhcp.nameservers;
            }
            {
              name = "domain-name";
              code = 15;
              space = "dhcp4";
              data = settings.services.dhcp.domain;
            }
          ];
        };
      };
    };
    samba = {
      enable = true;
      openFirewall = true;
      extraConfig = ''
        netbios name = ${settings.services.samba.netbios}
        workgroup = ${settings.services.samba.workgroup}
        passdb backend = ldapsam:ldap://localhost
        ldap admin dn = cn=admin,${ldapSuffix}
        ldap suffix = ${ldapSuffix}
        ldap user suffix = ou=users
        ldap group suffix = ou=groups
        ldap machine suffix = ou=computers
        ldap delete dn = no
        ldap ssl = no
        log file = /var/log/samba/log.session
        log level = 1
      '';
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
          upstream_dns = settings.services.dns.upstream;
          rewrites = settings.services.dns.records;
        };
      };
    };
    openldap = {
      enable = true;

      /* enable plain connections only */
      urlList = [ "ldap:///" ];

      settings = {
        attrs = {
          olcLogLevel = "conns config";
        };

        children = {
          "cn=module{0}".attrs = {
            objectClass = "olcModuleList";
            cn = "module{0}";
            olcModulePath = "${pkgs.openldap}/lib/modules";
            olcModuleLoad = [ "{1}pw-sha2.so" "{2}smbk5pwd" ];
          };

          "cn=schema".includes = [
            "${pkgs.openldap}/etc/schema/core.ldif"
            "${pkgs.openldap}/etc/schema/cosine.ldif"
            "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
            "${pkgs.openldap}/etc/schema/nis.ldif"
            "${../resources/config/openldap/schemas/krb5-kdc.ldif}"
            "${../resources/config/openldap/schemas/samba.ldif}"
          ];

          "olcDatabase={1}mdb" = {
            attrs = {
              objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

              olcDatabase = "{1}mdb";
              olcDbDirectory = "/var/lib/openldap/data";

              olcSuffix = ldapSuffix;

              /* your admin account, do not use writeText on a production system */
              olcRootDN = "cn=admin,${ldapSuffix}";
              olcRootPW = hashFn settings.services.openldap.adminPw;

              olcAccess = [
                /* custom access rules for userPassword attributes */
                ''{0}to attrs=userPassword
                    by self write
                    by anonymous auth
                    by * none''

                /* allow read on anything else */
                ''{1}to *
                    by * read''
              ]; 
            };

            children = {
              "olcOverlay={2}ppolicy".attrs = {
                objectClass = [ "olcOverlayConfig" "olcPPolicyConfig" "top" ];
                olcOverlay = "{2}ppolicy";
                olcPPolicyHashCleartext = "TRUE";
              };

              "olcOverlay={3}memberof".attrs = {
                objectClass = [ "olcOverlayConfig" "olcMemberOf" "top" ];
                olcOverlay = "{3}memberof";
                olcMemberOfRefInt = "TRUE";
                olcMemberOfDangling = "ignore";
                olcMemberOfGroupOC = "groupOfNames";
                olcMemberOfMemberAD = "member";
                olcMemberOfMemberOfAD = "memberOf";
              };

              "olcOverlay={4}refint".attrs = {
                objectClass = [ "olcOverlayConfig" "olcRefintConfig" "top" ];
                olcOverlay = "{4}refint";
                olcRefintAttribute = "memberof member manager owner";
              };
              "olcOverlay={5}smbk5pwd".attrs = {
                objectClass = [ "olcOverlayConfig" "olcSmbK5PwdConfig" ];
                olcOverlay = "{5}smbk5pwd";
                olcSmbK5PwdEnable= "samba";
                olcSmbK5PwdMustChange= "0";
              };
            };
          };
        };
      };
    };
    # printing.enable = true;
  };
}

