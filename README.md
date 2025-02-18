# Reboot/Fitz uses NixOS btw.

Basically, we have a bad habit of breaking our linux installs all the damn time, so we decided to move to NixOS to make sure that we could a) roll back to not-borked configuration (this is especially useful when we fucked up KDE), or b) entirely rebuild our linux install from scratch if we need to (which happens concerningly often).

## Layout

This repo is designed for you to just `sudo git clone https://github.com/Reboot-Codes/dotfiles nixos` in `/etc`. Then just `nixos-rebuild switch --flake /etc/nixos/# --impure -L --show-trace`. Note: you'll have to specify the hostname when you install the first time. That's standard procedure in NixOS though, so we expect that you understand that already. There's a lot of weird shit going on in the files to make sure that the nix package flow is... working and whatnot, but it basically is designed to be idiosyncratic once you learn where everything is defined. (Check for any `import` statements, basically.)

We're working on a CLI to make sure that everything runs smoothly, but in the meantime, we hope you know a bit about using flakes instead of plain expressions. Or, just google with `nix flake` or something.

### Common Nix Expressions

`common` is probably what you actually want to check out since it holds the most configuration by far. (Anything that's shared between systems such as home configuration, kernel, grub theme, etc.)

#### Home

Home configurations are split into the common home file which makes sure that stuff like my ZSH environment, Terminal, TMUX, etc are all the same, as well as some commonly fucked up core things like using GPG for SSH auth, etc; the configs which are more machine type specific like running ARPC for Vesktop/Vencord; and then the package groups (which package groups are used depends on the configuration used when building as seen previously).

#### NixOS

NixOS common configurations live here and makes sure that there is (mostly) no "it works on this machine, but not this one". And mostly revolves around some linux admin best practicies and personal preference.

#### Derivations

This is where fully custom packages live, like the grub theme.

#### Overlays

Any mods to stuff in `nixpkgs` lives here, mostly enabling non-default features or adding patches.

#### Utils

Other random common shit like nix-alien (which is unused atm).

### NixOS

This contains NixOS configurations for each machine (if they happen to have NixOS installed, that is), and is mostly hardware specific stuff. Defining a new system is basically:

1. Choose if you want to use Disko
   1. if you do: write the disko config and copy an existing configuration in the `nixos` directory, add a disko config, tell the `nixos/default.nix` file to use disko with that new configuration, and boot the install iso, clone this repo.
   2. if you don't, boot the install iso, partition, mount partitions, then generate a hardware config. Clone this repo, and copy an existing configuration from the `nixos` directory, and then move the hardware configuration to that new directory, tell the `nixos/default.nix` file about it.
2. nixos-install like normal but tell it to use this flake/repo with the hostname you REMEMBERED TO SET, RIGHT?
3. Set the root password, and the user's password too while you're in the chroot.
4. Reboot the pc!

### Scripts

Utility scripts while we figure out how to make a CLI like home-manager has, mostly to build custom installation ISOs. (The nix invocation for that is weird af.)
