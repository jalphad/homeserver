# Define user accounts. Don't forget to set a password with ‘passwd’.
{
  users = {
    users = {
      nixhome = {
        isNormalUser = true;
        extraGroups = [ "wheel" "ssh-users" "docker" "media" ]; # Enable ‘sudo’ for the user.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILk9J5Labk84GXRWOUBETbIhEw8kKq/jR5aISL52/HBH home@nixos"
        ];
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
      jellyfin = {
        isNormalUser = true;
        group = "media";
        createHome = true;
        uid = 10003;
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
        createHome = true;
        group = "media";
        uid = 10008;
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
    };
  };
}