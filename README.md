# homeserver

## Install
- Boot from usb
- Prepare filesystem
- Mount OS partition on /mnt
- Mount Boot partition on /mnt/boot
- Execute:
```nix
nixos-install --root /mnt --flake /mnt/etc/nixos#homeserver
```
- Reboot

## Update
- Git pull latest update to `/etc/nixos`
- Execute:
```nix
sudo nixos-rebuild switch --flake /etc/nixos/#homeserver --impure
```
*Adding `--impure` because the personal-accounts.nix file is not part of the flake.*

