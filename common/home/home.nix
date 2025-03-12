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

      # TODO: Translate oh-my-zsh plugins.

      envExtra = ''
        if [ -e /bin ]; then
          PATH="$PATH:/bin"
        fi

        if [ -e /usr/bin ]; then
          PATH="$PATH:/usr/bin"
        fi

        if [ -e /usr/sbin ]; then
          PATH="$PATH:/usr/sbin"
        fi

        if [ -e /run/current-system/sw/bin ]; then
          PATH="$PATH:/run/current-system/sw/bin"
        fi

        if [ -e ~/dev/scripts/remind.sh ]; then
          source ~/dev/scripts/remind.sh
        fi

        if [ -e /home/reboot/.local/bin ]; then
          PATH="$PATH:~/.local/bin"
        fi

        if [ -e ~/dev/bin ]; then
          PATH="$PATH:~/dev/bin"
        fi

        if [ -e ~/bin ]; then
          PATH="$PATH:~/bin"
        fi

        if [ -e ~/.config/emacs/bin ]; then
          PATH="$PATH:~/.config/emacs/bin"
        fi

        if command -v eza &> /dev/null; then
          alias ll="eza -l --icons"
          alias ls="eza --icons"
          alias tree="eza --icons --tree --git-ignore"
        fi

        if command -v cargo-mommy &> /dev/null; then
          export CARGO_MOMMYS_PRONOUNS="his/their"
          export CARGO_MOMMYS_LITTLE="boy/pup/puppy"
          export CARGO_MOMMYS_ROLES="daddy/master/owner/handler"
          export CARGO_MOMMYS_MOODS="chill/ominous/thirsty/yikes"
          export CARGO_MOMMYS_PARTS="milk/dick/ass/paws/pits/pecs/muscles/musk/piss/balls"
          export CARGO_MOMMYS_FUCKING="slut/toy/pet/pervert/whore/pup/cocksleeve/puppy"

          alias cargo-daddy="cargo-mommy"
        fi

        if command -v fastfetch &> /dev/null; then
          if command -v fortune &> /dev/null; then
            if command -v lolcat &> /dev/null; then
              alias sclear="clear; fastfetch && fortune | lolcat"
            fi
          fi
        fi

        if command -v wget &> /dev/null; then
          alias wayback-download="wget --recursive --no-clobber --page-requisites --convert-links --domains web.archive.org --no-parent"
        fi

        if command -v nix-store &> /dev/null; then
          alias nix-clean="nix-store --gc"
        fi

        if [ "$SSH_CLIENT" ]; then
          export PINENTRY_USER_DATA=pinentry-curses
        fi

        unset SSH_AGENT_PID
        if [ "''\${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
          export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        fi
        export GPG_TTY=$(tty)
        gpg-connect-agent updatestartuptty /bye >/dev/null

        PATH="$PATH:."

        # hhdfhgh this don't work.
        # bindkey  "^[[1~"   beginning-of-line
        # bindkey  "^[[4~"   end-of-line
        # bindkey  "^[[3~"   delete-char

        # Check if this session is interactive (fix `scp` lmao)
        if [[ $- == *i* ]]; then
          # Runs tmux on ssh conn, see: https://stackoverflow.com/a/40192494
          if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
            tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
          fi

          fastfetch
          fortune | lolcat
        fi
      '';
    };

    git = {
      userName = "Reboot-Codes";
      userEmail = "git@reboot-codes.com";

      signing = {
        key = "F4DB81CBA107C76D0F7A75B18A0D03A6C3DCBA53";
        signByDefault = true;
      };

      aliases = {
        pushall = "!git remote | xargs -L1 git push --all";
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;

      plugins = with pkgs; [
        vimPlugins.lightline-vim
      ];

      # TODO: Configure lightline.
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

      extraConfig = ''
        # Use CRTL+A, | to split horizontally
        bind | split-window -h
        # Use CRTL+A, - to split vertically
        bind - split-window -v
        # Remove old splitting keybinds
        unbind '"'
        unbind %

        # Use CRTL+A, R to reload the config.
        bind r source-file ~/.config/tmux/tmux.conf

        # Use CRTL+A, q to close a pane (window)
        bind q killp

        # Use ALT+[ARROW] to switch between panes.
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Enable mouse mode by default.
        set -g mouse on

        # DESIGN TWEAKS, see: https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/
        # don't do anything when a 'bell' rings
        set -g visual-activity off
        set -g visual-bell off
        set -g visual-silence off
        setw -g monitor-activity off
        set -g bell-action none

        # clock mode
        setw -g clock-mode-colour colour1

        # copy mode
        setw -g mode-style 'fg=colour1 bg=colour18 bold'

        # pane borders
        set -g pane-border-style 'fg=colour6'
        set -g pane-active-border-style 'fg=colour3'

        # statusbar
        set -g status-position bottom
        set -g status-justify left
        set -g status-style 'fg=colour6'
        set -g status-left ""
        set -g status-right '%Y-%m-%d %H:%M '
        set -g status-right-length 50
        set -g status-left-length 10

        setw -g window-status-current-style 'fg=colour0 bg=colour6 bold'
        setw -g window-status-current-format ' #I #W #F '

        setw -g window-status-style 'fg=colour7 dim'
        setw -g window-status-format ' #I #[fg=colour7]#W #[fg=colour1]#F '

        setw -g window-status-bell-style 'fg=colour2 bg=colour1 bold'

        # messages
        set -g message-style 'fg=colour2 bg=colour0 bold'
      '';
    };

    alacritty = {
      enable = true;

      settings = {
        general.live_config_reload = true;

        bell = {
          animation = "EaseOutExpo";
          color = "0x555555";
          duration = 200;
        };

        colors = {
          bright = {
            black = "#928374";
            blue = "#83a598";
            cyan = "#8ec07c";
            green = "#b8bb26";
            magenta = "#d3869b";
            red = "#fb4934";
            white = "#ebdbb2";
            yellow = "#fabd2f";
          };

          normal = {
            black = "#282828";
            blue = "#458588";
            cyan = "#689d6a";
            green = "#98971a";
            magenta = "#b16286";
            red = "#cc241d";
            white = "#a89984";
            yellow = "#d79921";
          };

          primary = {
            background = "#000000";
            foreground = "#ffffff";
          };
        };

        cursor.style = "Beam";

        env = {
          "TERM" = "xterm-256color";
        };

        font = {
          size = 10.0;

          bold = {
            family = "JetBrainsMono NF ExtraBold";
            style = "Normal";
          };

          bold_italic = {
            family = "JetBrainsMono NF ExtraBold";
            style = "Italic";
          };

          italic = {
            family = "JetBrainsMono NF Medium";
            style = "Italic";
          };

          normal = {
            family = "JetBrainsMono NF Medium";
            style = "Normal";
          };
        };

        scrolling = {
          history = 100000;
          multiplier = 1;
        };

        selection = {
          save_to_clipboard = true;
          semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
        };

        terminal.shell = {
          args = ["-l" "-c" "tmux attach || tmux"];
          program = "zsh";
        };
      };
    };

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
