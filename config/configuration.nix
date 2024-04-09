# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ];
  };

  networking = {
    hostName = "homeserver";
    domain = "lan.mejora.dev";
    useDHCP = false;
    interfaces.enp2s0.ipv4.addresses = [
      {
        address = "192.168.178.2";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.178.1";
    nameservers = [ "192.168.178.2" ];
    firewall = {
      enable = false;
      allowedTCPPorts = [ 2022 8096 1900 7359];
      allowedUDPPorts = [ 53 ];
    };
  };

  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  systemd.services.k3s.path = [ pkgs.ipset ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev:
      {
        # nixpkgs:/pkgs/development/libraries/openldap
        openldap = prev.openldap.overrideAttrs (_: rec {
            extraContribModules = [
              # https://git.openldap.org/openldap/openldap/-/tree/master/contrib/slapd-modules
              "passwd/sha2"
              "passwd/pbkdf2"
              "passwd/totp"
              "smbk5pwd"
            ];
        })
      }
    )
  ];

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      allowed-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly"; # Mon *-*-* 00:00:00
      options = "--delete-older-than +5 --max-freed $((64 * 1024**3))";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  system = {
    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    stateVersion = "23.11";
#    autoUpgrade = {
#      enable = true;
#      allowReboot = true;
#      flake = "github:jdirkse/homeserver";
#      flags = [
#        "--recreate-lock-file"
#        "--no-write-lock-file"
#        "-L" # print build logs
#       ];
#      dates = "daily";
#    };
  };
}