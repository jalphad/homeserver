{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
#    k3s
#    cilium-cli
#    kubernetes-helm
  ];
}