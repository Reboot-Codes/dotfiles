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
}
