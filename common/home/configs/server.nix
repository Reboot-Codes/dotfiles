{ pkgs, lib, pwndbg ? null, ... }: {
  home = {
    packages = with pkgs; [
      # Terminal & system monitoring
      htop
      btop
      iotop
      iftop

      # Utilities
      eza
      bat
      ripgrep
      fd
      jq
      tree
      file
      which
      unzip
      zip
      p7zip
      socat
      nmap
      fastfetch

      # Networking
      curl
      wget
      rsync
    ] ++ lib.optional (pwndbg != null) pwndbg;

    sessionVariables = {
      # Clear desktop-specific environment variables
      GTK_THEME = lib.mkForce "";
      NIXOS_OZONE_WL = lib.mkForce "";
    };
  };

  # Disable GUI / Desktop applications on headless server
  programs = {
    alacritty.enable = lib.mkForce false;
    vicinae.enable = lib.mkForce false;
    hyprlock.enable = lib.mkForce false;
    waybar.enable = lib.mkForce false;
  };

  wayland.windowManager.hyprland.enable = lib.mkForce false;

  # Use curses-based pinentry on servers without GUI
  services.gpg-agent.pinentry.package = lib.mkDefault pkgs.pinentry-curses;
}
