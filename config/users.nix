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
        createHome = false;
        uid = 10003;
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
      media = {};
    };
  };
}