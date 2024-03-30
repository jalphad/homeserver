{ pkgs, ... }:

let 
  unfree-p7zip = pkgs.p7zip.override {
    enableUnfree = true;
  };
in 
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    unfree-p7zip
  ];
}