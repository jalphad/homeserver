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
              overlay-unstable = final: prev: {
                unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
              };
              personalAccounts = /etc/homeserver/config/personal-accounts.nix;
            in
            {
              nixpkgs.overlays = [ overlay-unstable ];

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
                ] ++ (if builtins.pathExists personalAccounts then [ personalAccounts ] else []);
            }
          )
        ];
      };
    };
  };
}
