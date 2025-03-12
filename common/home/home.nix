# This file has general setting configs to make sure that our experiences are consistent.

{ config, pkgs, pkgs-stable, home-manager, ...}: {
  programs = {
    home-manager.enable = true;
    direnv.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      envExtra = builtins.readFile ./dotfiles/.zshrc;

			# TODO: Translate oh-my-zsh plugins.
    };

    git = {
      userName = "Reboot-Codes";
      userEmail = "git@reboot-codes.com";

      signing = {
        key = "F4DB81CBA107C76D0F7A75B18A0D03A6C3DCBA53";
        signByDefault = true;
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      extraLuaConfig = builtins.readFile ./dotfiles/init.lua;

			plugins = with pkgs.vimPlugins; [
        catppuccin-nvim
        {
          plugin = lightline-vim;

					# TODO: Configure lightline.
          config = ''
            let g:lightline = {'colorscheme': 'catppuccin'}
          '';
        }
      ];
    };

    starship = {
      enable = true;

      settings = {
        format = "$username$hostname$directory$all$line_break$character";

        directory = {
          read_only = " ";
          repo_root_style = "underline bold cyan";
        };

        character = {
          success_symbol = "[➜](bold green) ";
          error_symbol = "[➜](bold red) ";
        };

        username.show_always = true;
        aws.symbol = "  ";
        buf.symbol = " ";
        c.symbol = " ";
        conda.symbol = " ";
        dart.symbol = " ";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";
        haskell.symbol = " ";
        hg_branch.symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        memory_usage.symbol = " ";
        nim.symbol = " ";
        nix_shell.symbol = " ";
        nodejs.symbol = " ";
        package.symbol = " ";
        python.symbol = " ";
        spack.symbol = "🅢 ";
        rust.symbol = " ";
      };
    };

    tmux = {
      enable = true;
      mouse = true;
      shortcut = "a";
      historyLimit = 500000;

      plugins = with pkgs.tmuxPlugins; [
        tmux-powerline
        tmux-powerline
      ];

      extraConfig = builtins.readFile ./dotfiles/tmux.conf;
    };

    alacritty = import ./programs/alacritty.nix;

    hyprlock = {
      enable = true;

      settings = {
        general = {
          hide_cursor = true;
        };

        background = [{
          path = "screenshot";
          blur_passes = 4;
          blur_size = 8;
        }];

        input-field = [{
          size = "500, 50";
          font_color = "rgb(124, 207, 158)";
          inner_color = "rgb(0, 0, 0)";
          outline_color = "rgb(124, 207, 158)";
          dots_center = true;
        }];
      };
    };

    waybar = {
      enable = true;
      systemd.enable = false;

      settings = {
        main = {
          layer = "top";
					position = "top";
          height = 32;

          modules-left = [ "hyprland/workspaces" ];
          modules-center = [];
          modules-right = [ "battery" "clock" ];
        };
      };
    };

    # TODO: Configure KDE with `qt.kde.settings`
  };

  services = {
    gpg-agent = {
      enable = true;
      enableExtraSocket = true;
      enableSshSupport = true;
      sshKeys = [ "F4DB81CBA107C76D0F7A75B18A0D03A6C3DCBA53" ];
    };

    # emacs.enable = true;
  };

  # TODO: Translate alt DE configs (hyprland, hyprpapr, dunst, waybar)
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = let 
      toggle = program: "pkill ${program} || ${program}";
      runOnce = program: "pgrep ${program} || ${program}";
    in {
      "exec-once" = [
        "waybar"
        "dunst"
      ];

      "$mod" = "SUPER";

      bind = [
        "ALT, space, exec, ${toggle "wofi --show drun"}"
        "$mod, Return, exec, alacritty"
        "$mod, M, exit,"
				"$mod, BackSpace, killactive,"
				"SUPER, left, workspace, -1"
				"SUPER, right, workspace, +1"
        "SHIFT + SUPER, left, movetoworkspace, -1"
        "SHIFT + SUPER, right, movetoworkspace, +1"
				"$mod, L, exec, ${runOnce "hyprlock"}"
      ];
    };
  };
}
