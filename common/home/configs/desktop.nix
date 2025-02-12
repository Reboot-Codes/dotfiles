{ pkgs, pkgs-stable, pwndbg, lib, ... }: let
  groups = [
    "alien"
    "internet"
    "comms"
    "fs-manip"
    "office"
    "remote-access"
    "repair"
    "toys"
  ];
in {
  home = {
    # TODO: Cursor doesn't work.... guh...
    #pointerCursor =
    #  let
    #    getFrom = url: hash: name: sub_name: {
    #      gtk.enable = true;
    #      x11.enable = true;
    #      name = name;
    #      size = 32;
    #      package =
    #        pkgs.runCommand name {} ''
    #          mkdir -p $out/share/icons
    #          ln -s ${pkgs.fetchzip {
    #            url = url;
    #            hash = hash;
    #          }}/${sub_name} $out/share/icons/${sub_name}
    #        '';
    #    };
    #  in
    #    getFrom
    #      "https://github.com/Reboot-Codes/posy-improved-cursor-linux/archive/refs/heads/main.zip"
    #      "sha256-ndxz0KEU18ZKbPK2vTtEWUkOB/KqA362ipJMjVEgzYQ="
    #      "posy-improved-cursor-linux"
    #      "Posy_Cursor_Mono";

    packages = lib.flatten (
      builtins.map (groupName:
        (import (../packages + "/${groupName}.nix") { inherit pkgs pkgs-stable pwndbg; }).packages
      ) groups
    );
  };
}