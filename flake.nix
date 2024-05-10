{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }: {
    nixosConfigurations = {
      homeserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ config, pkgs, ... }:
            let
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
            in
            {
              nixpkgs.overlays = [ overlay-custom ];

              imports =
                [
                  ./config/hardware-configuration.nix
                  ./config/configuration.nix
                  ./config/packages.nix
                  ./config/users.nix
                  ./config/services.nix
                  ./config/virtualisation.nix
                  ./config/folders.nix
                  ./config/systemd.nix
                ];
            }
          )
        ];
      };
    };
  };
}
