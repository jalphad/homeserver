{pkgs, settings,...}:

# Define user accounts. Don't forget to set a password with ‘passwd’.
let
  ldapSuffixFn = import ../helpers/ldapsuffix.nix {lib=pkgs.lib;};
  ldapSuffix = ldapSuffixFn settings.domain;
in 
{
  users = {
    ldap = {
      enable = true;
      server = "ldap://localhost";
      base = ldapSuffix;
      bind = {
        distinguishedName = "cn=admin,${ldapSuffix}";
      };
      daemon = {
        enable = true;
      };
      nsswitch = true;
    };
    users = {
      nixhome = {
        isNormalUser = true;
        extraGroups = [ "wheel" "ssh-users" "docker" "media" ];
        openssh.authorizedKeys.keys = settings.sshKeys;
        createHome = true;
      };
      traefik = {
        isNormalUser = true;
        group = "traefik";
        extraGroups = [ "docker" ];
        createHome = true;
        uid = 10001;
      };
      portainer = {
        isNormalUser = true;
        group = "portainer";
        extraGroups = [ "docker" ];
        createHome = true;
        uid = 10002;
      };
      unifi = {
        isNormalUser = true;
        createHome = true;
        uid = 10004;
      };
      paperless = {
        isNormalUser = true;
        group = "paperless";
        createHome = false;
        uid = 10005;
      };
      scanner = {
        isNormalUser = true;
        extraGroups = [ "paperless" ];
        createHome = false;
        uid = 10006;
        hashedPassword = "$y$j9T$yT3mdjPQXc2foIJ5uNIub/$W0L76npj.vYIdsE/jnycGngw5MxMjdBrM2FiyjpHiLD";
      };
      nextcloud = {
        isNormalUser = true;
        createHome = false;
        uid = 10007;
        hashedPassword = "$y$j9T$Me.q9mQcb9PLZx6PmOb3a1$dBDX7BMwkX/YJWRlhDNOByrGjVzh06d6yYhg16.5C2B";
      };
      mediamgmt = {
        isNormalUser = true;
        createHome = false;
        group = "media";
        uid = 10008;
        home = "/data/media/mediamgmt";
      };
      keycloak = {
        isNormalUser = true;
        createHome = true;
        uid = 10009;
      };
      dashboard = {
        isNormalUser = true;
        createHome = true;
        uid = 10010;
      };
      radius = {
        isNormalUser = true;
        createHome = true;
        uid = 10011;
      };
    };
    groups = {
      ssh-users = {};
      traefik = {
        gid = 10001;
      };
      portainer = {
        gid = 10002;
      };
      media = {
        gid = 10003;
      };
      paperless = {
        gid = 10004;
      };
      lldap = {
        gid = 10005;
      };
    };
  };
}