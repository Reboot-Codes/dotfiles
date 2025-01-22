{
  imports = [ ./configuration.nix ./home.nix ];

  home-manager.users."reboot" = ../../common/home;
}