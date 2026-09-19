{ pkgs, lib, nix-darwin ? null, ... }: {
  home = {
    stateVersion = lib.mkDefault "24.11";
    username = lib.mkDefault "reboot";
    homeDirectory = lib.mkDefault "/Users/reboot";

    packages = with pkgs; [
      # Core utilities
      coreutils
      curl
      wget
      git
      jq
      ripgrep
      fd
      eza
      fzf
      bat
      fastfetch
      fortune
      lolcat
      tree
      gnupg
      pinentry_mac
      gh
      lazygit
      nerd-fonts.jetbrains-mono
    ] ++ lib.optionals (nix-darwin != null) [
      (nix-darwin.packages.${pkgs.stdenv.hostPlatform.system}.darwin-rebuild or nix-darwin.packages.${pkgs.stdenv.hostPlatform.system}.default)
    ];
  };

  programs.alacritty.settings.font = lib.mkForce {
    size = 13.0;

    normal = {
      family = "JetBrainsMono Nerd Font";
      style = "Medium";
    };

    bold = {
      family = "JetBrainsMono Nerd Font";
      style = "ExtraBold";
    };

    italic = {
      family = "JetBrainsMono Nerd Font";
      style = "Medium Italic";
    };

    bold_italic = {
      family = "JetBrainsMono Nerd Font";
      style = "ExtraBold Italic";
    };
  };
}
