{ pkgs, pkgs-stable, ... }: {
  systemd.user.services = {
    arrpc = {
      Unit = {
        Description = "Run arRPC";
      };

      Install = {
        After = [ "network.target" ];
        WantedBy = [ "default.target" ];
      };

      Service = {
        ExecStart = "${pkgs.arrpc}/bin/arrpc";
      };
    };

    arrpc-socket-link = {
      Unit = {
        Description = "Create arRPC socket";
      };

      Install = {
        After = [ "arrpc.service" ];
        WantedBy = [ "default.target" ];
      };

      Service = {
        ExecStart = "ln -s /tmp/discord-ipc-0 /run/user/$(id -u)/discord-ipc-0";
      };
    };
  };


  xdg.desktopEntries = {
    "renpy" = {
      name = "RenPy";
      exec = "${pkgs.renpy}/bin/renpy";
    };

    "Vital" = {
      name = "Vital";
      exec = "${pkgs.vital}/bin/Vital";
    };
  };

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

    packages = import ./get-packages.nix {
      inherit pkgs pkgs-stable;

      groups = [
        "alien"
        "internet"
        "avi"
        "comms"
        "crypto"
        "dev"
        "fs-manip"
        "games"
        "hacking"
        "horny"
        "maps"
        "media-acquisition"
        "object-creation"
        "office"
        "remote-access"
        "repair"
        "toys"
      ];
    };
  };
}