{ config, pkgs, pkgs-stable, home-manager, ...}: {
  imports = [ ../../common/home ];

  # TODO: packages to package sets in common/home/packages

  home = {
    stateVersion = "24.11";
    username = "reboot";
    homeDirectory = "/home/reboot";

    packages = with pkgs; [
      pinentry.qt
      starship
      fortune
      lolcat
      eza
      zsh
    ];
  };

  programs.alacritty.package = pkgs.empty;

  services.gpg-agent = {
    pinentryPackage = pkgs.pinentry.qt;
  };
}
