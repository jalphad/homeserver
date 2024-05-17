{pkgs,settings,...}:

with pkgs;
let 
  ldapSuffixFn = import ./helpers/ldapsuffix.nix {lib=pkgs.lib;};
  ldapSuffix = ldapSuffixFn settings.domain;
in
rec {
  modLdap = writeText "ldap" 
  ''
  ldap {
    # example - identity = 'cn=readonly,dc=example,dc=com'
    identity = 'cn=admin,${ldapSuffix}'

    # example - password = 'readonly'
    password = '${settings.services.openldap.adminPw}'

    # example - server = ldap://localhost
    server = 'ldap://${settings.hostname}.${settings.domain}:389'

    # example - base_dn = 'dc=example,dc=com'
    base_dn = '${ldapSuffix}'

    update {
      control:Password-With-Header	+= 'userPassword'
      control:NT-Password		:= 'sambaNTPassword'
    }

    user {
      # example - base_dn = "ou=people,''${..base_dn}"
      base_dn = "ou=users,''${..base_dn}"  

      # example = "(&(uid=%{&Stripped-User-Name || &User-Name)(objectClass=posixAccount))"
      filter = "(&(uid=%{User-Name})(objectClass=inetOrgPerson))"  
    }
  }
  '';
  modEap = writeText "eap"
  ''
  eap {
    default_eap_type = peap

    timer_expire = 60

    ignore_unknown_eap_types = no

    cisco_accounting_username_bug = no

    max_sessions = ''${max_requests}

    ############################################################
    #
    #  Supported EAP-types
    #

    tls-config tls-common {
      private_key_password = whatever
      private_key_file = ''${certdir}/server.pem
      certificate_file = ''${certdir}/server.pem

      ca_file = ''${certdir}/ca.pem
      ca_path = ''${certdir}

      tls_min_version = "1.2"
      tls_max_version = "1.2"
    }

    peap {
      tls = tls-common

      default_eap_type = mschapv2

      copy_request_to_tunnel = no

      use_tunneled_reply = no

      virtual_server = "inner-tunnel"
    }

    mschapv2 {
      send_error = yes
      identity = "HomeServer"
    }
  }
  '';
  modMschap = writeText "mschap"
  ''
  mschap {
    pool {
      start = 0
      min = 0
      max = 0
      spare = 0
      uses = 0
      retry_delay = 30
      lifetime = 86400
      cleanup_interval = 300
      idle_timeout = 600
    }

    passchange {
    }
  }
  '';
  modPap = writeText "pap"
  ''
  pap{
  }
  '';
  modRadutmp = writeText "radutmp"
  ''
  radutmp {
    filename = ''${logdir}/radutmp
    username = %{User-Name}
    case_sensitive = yes
    check_with_nas = yes
    permissions = 0600
    caller_id = "yes"
  }
  '';
  freeradiusMods = symlinkJoin {
    name = "freeradiusMods";
    paths = [
      modEap
      modLdap
      modMschap
      modPap
      modRadutmp
    ];
  };
  siteHomeServer = writeText "home-server"
  ''
  server home-server {
    listen {
        type = auth
        ipaddr = *
        port = 1812
    }

    authorize {
        filter_username
        eap {
            ok = return
            updated = return
        }
    }

    authenticate {
        Auth-Type EAP {
            eap
        }
    }

    session {
        # radutmp
    }

    post-auth {
        Post-Auth-Type REJECT {
            eap
        }

        Post-Auth-Type Challenge {
    #        remove_reply_message_if_eap
    #        attr_filter.access_challenge.post-auth
        }
    }

    pre-proxy {

    }

    post-proxy {
        eap
    }
  }

  '';
  siteInnerTunnel = writeText "inner-tunnel"
  ''
  server inner-tunnel {
    listen {
        ipaddr = 127.0.0.1
        port = 18120
        type = auth
    }

    authorize {
      ldap
      pap
      eap {
        ok = return
      }
    }

    authenticate {
      Auth-Type EAP {
        eap
      }

      Auth-Type MS-CHAP {
        mschap
      }
    }

    ######################################################################
    #
    #	There are no accounting requests inside of EAP-TTLS or PEAP
    #	tunnels.
    #
    ######################################################################

    session {
      radutmp
    }

    post-auth {
      if (0) {
        update reply {
          User-Name !* ANY
          Message-Authenticator !* ANY
          EAP-Message !* ANY
          Proxy-State !* ANY
          MS-MPPE-Encryption-Types !* ANY
          MS-MPPE-Encryption-Policy !* ANY
          MS-MPPE-Send-Key !* ANY
          MS-MPPE-Recv-Key !* ANY
        }

        update {
          &outer.session-state: += &reply:
        }
      }

      Post-Auth-Type REJECT {
        update outer.session-state {
          &Module-Failure-Message := &request:Module-Failure-Message
        }
      }
    }

    pre-proxy {

    }

    post-proxy {
      eap
    }

  } # inner-tunnel server block
  
  '';
  freeradiusSites = symlinkJoin {
    name = "freeradiusSites";
    paths = [
      siteHomeServer
      siteInnerTunnel
    ];
  };
  clientsConf = writeText "clients.conf"
  ''
  client home_clients {
    ipaddr = ${settings.network.subnet}
    secret = ${settings.compose.freeradius.clientSecret}
    nas_type = other
  }
  '';
  compose = (pkgs.formats.yaml {}).generate "freeradius.yaml" {
    version = "2.4";
    services = {
      freeradius = {
        image = "freeradius/freeradius-server:latest";
        container_name = "radius";
        command = [];
          # - "-X"
        volumes = [
          {
            type = "bind";
            source = freeradiusMods;
            target = "/etc/raddb/mods-enabled";
            read_only = true;
          }
          {
            type = "bind";
            source = freeradiusSites;
            target = "/etc/raddb/sites-enabled";
            read_only = true;
          }
          {
            type = "bind";
            source = clientsConf;
            target = "/etc/raddb/clients.conf";
            read_only = true;
          }
          {
            type = "bind";
            source = "/home/radius/raddb/certs";
            target = "/etc/raddb/certs";
            read_only = true;
          }
        ];
        ports = [
          "1812:1812/udp"
          "1813:1813/udp"
        ];
        restart = "unless-stopped";
        networks = [ "traefik" ];
      };
    };
    networks = {
      traefik = {
        external = true;
      };
    };
  };
} 

