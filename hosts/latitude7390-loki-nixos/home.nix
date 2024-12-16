# Home-Manager Module by Reboot-Codes on 2024-08-02
{ config, pkgs, pkgs-stable, ...}: {
  home-manager = {
    backupFileExtension = "hm-bak";

    useGlobalPkgs = true;
    useUserPackages = true;

    users."reboot" = {
      nixpkgs.overlays = [
        (final: prev: {
          spotify = prev.spotify // {
            installPhase =
              builtins.replaceStrings [
                "runHook postInstall"
                ''
                  bash <(curl -sSL https://spotx-official.github.io/run.sh) -P "$out/share/spotify"
                  runHook postInstall
                ''
              ]
              prev.spotify.installPhase;
          };
        })
      ];

      xdg.desktopEntries."renpy" = {
        name = "RenPy";
        exec = "${pkgs.renpy}/bin/renpy";
      };

      # TODO: Configure syncthing

      home = {
        stateVersion = "23.11";
        username = "reboot";
        homeDirectory = "/home/reboot";

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

        packages = let
          unstable = with pkgs; [
            kdePackages.krfb

            # Internet
            firefox-devedition
            tor-browser-bundle-bin
            brave
            onioncircuits
            lokinet
            persepolis
            motrix
	          ungoogled-chromium
            megasync

            # Games (see stable)
            prismlauncher
            steamcmd
            steam-run
            ryujinx
            dolphin-emu
            # retroarchFull # THIS TAKES AGES AND COMPILES FROM SCRATCH
            the-powder-toy
            openttd
            gzdoom
            openrct2
            r2modman
	          ruffle

            (lutris.override {
              extraLibraries = pkgs: [
                pkgs.libunwind
                gdk-pixbuf
              ];

              extraPkgs = pkgs: [
                # List package dependencies here
              ];
            })

            itch
            itchiodl
            mangohud

            # Dev
            vscode
            vscodium-fhs
            (lib.hiPrio vscodium)
            starship
            kate
            openldap
            openssl
            pinentry-curses
            gcc_multi
            cmake
            jdk17
            # jdk8
            deno
            gh
            act
            codeberg-cli
            codeberg-pages
            zsh
            git
            renpy
            godot_4
            android-studio
            android-tools
            pipx
            python3Full
            filezilla
            powershell

            (symlinkJoin {
              name = "idea-community";
              paths = [ jetbrains.idea-community ];
              buildInputs = [ makeWrapper ];

              # stuff to make MC modding work.
              postBuild = ''
                wrapProgram $out/bin/idea-community \
                --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [libpulseaudio libGL glfw openal stdenv.cc.cc.lib]}"
              '';
            })

            fzf
            x11docker
            arduino
            arduino-ide
            screen
            minipro
            rust-bin.stable.latest.default
            pandoc
	          qemu

            # Object Creation (check stable)
            fritzing
            qmk
	          mission-planner
            brlcad
            solvespace
            (lib.hiPrio freecad)
            rpi-imager
            usbimager

            # FS Manipulation
            btrfs-progs
            exfat
            fuzzel
            virtiofsd
            p7zip
            fuse-7z-ng
            bchunk

            # Run Alien Software
            dosbox-x
            bottles
            looking-glass-client
            distrobox
            boxbuddy

            # Remote access (see stable)
            parsec-bin
            remmina
            moonlight-qt
            teamviewer
            anydesk

            # A/V/I (check stable)
            kdenlive
            audacity
            polyphone
            qsynth
            gimp-with-plugins
            krita
            vlc
            obs-studio
            obs-studio-plugins.obs-multi-rtmp
            obs-studio-plugins.obs-mute-filter
            obs-studio-plugins.input-overlay
            obs-studio-plugins.obs-gstreamer
            obs-studio-plugins.waveform
            obs-studio-plugins.obs-3d-effect
            obs-studio-plugins.looking-glass-obs
            obs-cli
            lmms
            handbrake
            easyeffects
            imagemagickBig
            carla
            rnnoise
            rnnoise-plugin
            sdrpp
            gqrx
            cubicsdr
            amarok
            strawberry-qt6
            elisa
            drawpile

            # Media Acquisition
            ani-cli
            losslessaudiochecker
            transmission_4-qt
            qbittorrent
            unshield
            spotify
	          youtube-music
	          ytmdl
            ipget
            torsocks
            lbry
            guymager
            vcdimager
            gImageReader

            # Comms
            zoom-us
            session-desktop
            telegram-desktop
            thunderbird
            element-desktop
            discord
            signal-cli
            signalbackup-tools
            signal-export
            sigtop
            # check system flatpak config for signal desktop

            # System
            libsForQt5.kclock
            libsForQt5.kleopatra

            # Office (see stable)
            keepassxc
            libreoffice-qt
            hunspell
            hunspellDicts.en-us
            hunspellDicts.de-de
            hunspellDicts.es-mx
            kcalc
            zotero
            obsidian
            emacs-gtk
            organicmaps
            kiwix
            kiwix-tools
            zim
            zim-tools
            pdfslicer

            # Crypto (see stable)
            monero-gui
            monero-cli
            xmrig

            # Cool shit
            cmatrix
            cool-retro-term
            sl

            # Repair
            gparted
            ventoy-full
            idevicerestore

            # Hacking (see stable)
            wireshark
            ettercap
            bettercap
            ida-free # TODO: Crack this mofo
            ghidra
            ghidra-extensions.ret-sync
            # ghidra-extensions.findcrypt
            ghidra-extensions.lightkeeper
            ghidra-extensions.sleighdevtools
            ghidra-extensions.machinelearning
            ghidra-extensions.gnudisassembler
            ghidra-extensions.ghidraninja-ghidra-scripts
            ghidra-extensions.ghidra-delinker-extension
            radare2
            iaito
            veracrypt

            # Horny
            intiface-central
            cargo-mommy
            cargo-vibe
          ];

          stable = with pkgs-stable; [ # Some stuff is broken on the unstable branch
            # Internet
            onionshare-gui

            # Office
            logseq

            # Object creation
            kicad
            orca-slicer

            # Remote Access
            (lib.hiPrio rustdesk-flutter)

            # A/V/I
            blender

            # Maps
            qgis
            josm

            # Games
            steam-tui

            # Crypto
            electrum
            electrum-ltc

            # Hacking
            rizin
            rizinPlugins.rz-ghidra
            cutter
            cutterPlugins.sigdb
            cutterPlugins.jsdec
            cryptomator
          ];
        in
          unstable ++ stable;
      };
    };
  };
}
