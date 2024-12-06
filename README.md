# Reboot/Fitz uses NixOS btw.

Basically, we have a bad habit of breaking our linux installs all the damn time, so we decided to move to NixOS to make sure that we could a) roll back to not-borked configuration (this is especially useful when we fucked up FDE), or b) entirely rebuild our linux install from scratch if we need to.

## Layout

This repo is designed for you to just `sudo git clone https://github.com/Reboot-Codes/dotfiles nixos` in `/etc`. Then just `nixos-rebuild switch --flake /etc/nixos/# --impure -L --show-trace`. Note: you'll have to specify the hostname when you install the first time. That's standard procedure in NixOS though, so we expect that you understand that already.

### Common Nix Expressions

`common` holds some utilities that we find useful to share between hosts, mostly a config for nix-alien (which we need to actually.... properly configure), and our home-manager config; which... also needs more work. DW about it! :33333

### Hosts

`hosts` is separated into folders for each host, and will contain a `home.nix` for user-specific programs, and the `configuration.nix` which will also import a `hardware-configuration.nix` which is usually also in that folder. In general though, the host config in `flake.nix` will import a `default.nix` from that host's directory instead.
