# Home-Manager Module by Reboot-Codes on 2024-08-02
{ config, pkgs, pkgs-stable, ...}: {
  home-manager = {
    users."reboot" = {
      # TODO: Configure syncthing

      home = {
        stateVersion = "23.11";
        username = "reboot";
        homeDirectory = "/home/reboot";
      };
    };
  };
}
