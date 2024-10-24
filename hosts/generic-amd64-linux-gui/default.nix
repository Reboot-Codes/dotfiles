{ config, pkgs, pkgs-stable, home-manager, ...}: {
  imports = [ ../../common/home.nix ];

  home = {
    stateVersion = "24.11";
    username = "reboot";
    homeDirectory = "/home/reboot";

    packages = with pkgs; [
      pinentry.qt
    ];
  };

  services.gpg-agent = {
    pinentryPackage = pkgs.pinentry.qt;
  };
}
