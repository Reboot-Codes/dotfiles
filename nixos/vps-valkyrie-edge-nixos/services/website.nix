{ ... }: {
  services.caddy.virtualHosts = {
    # Redirect cuz i'm too lazy to type "www."
    "reboot-codes.com".extraConfig = ''
      redir https://www.reboot-codes.com{uri} permanent
    '';

    # Serve static website directly
    "www.reboot-codes.com" = {
      extraConfig = ''
        import waf
        import default_robots

        root * /var/www/reboot-codes.com
        file_server
      '';
    };
  };
}
