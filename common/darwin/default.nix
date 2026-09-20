{ pkgs, ... }: {
  # Ensure nix-darwin manages zsh so system and nix-profile binaries are in PATH
  programs.zsh.enable = true;

  # Flake support and trusted users
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [
      "root"
      "reboot"
      "@admin"
    ];
  };

  # State version for nix-darwin
  system.stateVersion = 5;

  # User definition for macOS
  users.users.reboot = {
    name = "reboot";
    home = "/Users/reboot";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  system = {
    primaryUser = "reboot";

    defaults = {
      dock = {
        # IF I WANTED MRU, I'D USE THE SAME FUCKIN' DESKTOP, APPLE.
        mru-spaces = false;
      };

      trackpad = {
        Clicking = true;
        Dragging = true;
      };

      controlcenter = {
        BatteryShowPercentage = true;
      };

      finder = {
        ShowStatusBar = true;
        NewWindowTarget = "Home";
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };
    };
  };

  homebrew = {
    enable = true;
    enableZshIntegration = true;

    casks = [
      # Web
      "firefox@developer-edition"

      # Dev
      "zed"

      # Security
      "keepassxc"

      # Sync
      "syncthing-app"
      "tailscale-app"

      # Util
      "vorssaint"
    ];

    brews = [
      "wget"
      "neovim"
      "tmux"
    ];
  };
}
