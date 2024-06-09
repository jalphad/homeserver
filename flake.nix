{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { nixpkgs, nixpkgs-unstable, sops-nix, ... }:
    let
      system = "x86_64-linux";
      settings = import ./config/vars/settings.nix;
      overlay-custom = final: prev: rec {
        unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;

        heimdal-modified = unstable.heimdal.overrideAttrs ({postInstall ? "", ...}: {
          postInstall = postInstall + ''
          cp include/heim_threads.h $dev/include
          '';
        });

        heimdal-noldap = heimdal-modified.override {
          withOpenLDAP = false;
        };

        # nixpkgs:/pkgs/development/libraries/openldap
        openldap = unstable.openldap.overrideAttrs (a: {
          doCheck = true;
          buildInputs = a.buildInputs ++ [heimdal-noldap];

          extraContribModules = a.extraContribModules ++ [
            "smbk5pwd"
          ];
        });

        samba = prev.samba.override {
          enableLDAP = true;
        };
      };
    in {
      nixosConfigurations = {
        homeserver = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-custom ];
            })
            ./config/hardware-configuration.nix
            ./config/configuration.nix
            ./config/packages.nix
            ./config/users.nix
            ./config/services.nix
            ./config/virtualisation.nix
            ./config/folders.nix
            ./config/systemd.nix
            { _module.args = { inherit settings; };}
            sops-nix.nixosModules.sops
            {
              sops = {
                defaultSopsFile = ./secrets/secrets.yaml;
                age.sshKeyPaths = ["/etc/ssh/sopsnix_ed25519"];
                secrets = {
                  "lego.key" = {};
                  "traefik.key" = {};
                  "keycloak.env" = {};
                };
              };
            }
          ];
        };
      };
    };
}
