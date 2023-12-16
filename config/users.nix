# Define user accounts. Don't forget to set a password with ‘passwd’.
{ lib, ... }:

let
  path = users/personal-accounts.nix;
  personal = if (builtins.pathExists path) then (import path) else {};
  fnMerge = (import "${../helpers/merge.nix}"){lib=lib;};
in
{
  users = fnMerge [ {
    users = {
      nixhome = {
        isNormalUser = true;
        extraGroups = [ "wheel" "ssh-users" ]; # Enable ‘sudo’ for the user.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILk9J5Labk84GXRWOUBETbIhEw8kKq/jR5aISL52/HBH joren@nixos"
        ];
        createHome = true;
      };
    };
    groups = {
      ssh-users = {};
    };
  } personal ];
}