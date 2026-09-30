{ ... }: {
  services.caddy.virtualHosts = {
    # Redirect cuz i'm too lazy to type "www."
    "reboot-codes.com".extraConfig = ''
      redir https://www.reboot-codes.com{uri} permanent
    '';

    # Public Anubis proxy
    "www.reboot-codes.com" = {
      extraConfig = ''
        import waf
        import default_robots

        reverse_proxy http://127.0.0.1:8923 {
          import cloudflare_trusted
          # Ensure real client IP reaches Anubis for challenge validation
          header_up X-Real-IP {http.request.header.CF-Connecting-IP}
        }
      '';
    };

    # Inner static origin
    "http://:8080" = {
      extraConfig = ''
        root * /var/www/reboot-codes.com
        file_server
      '';
    };
  };

  virtualisation.oci-containers.containers.anubis-website = {
    image = "ghcr.io/techarohq/anubis:latest";
    autoStart = true;

    extraOptions = [ "--network=host" ];

    environment = {
      BIND = ":8923";
      TARGET = "http://127.0.0.1:8080";
      COOKIE_DOMAIN = "www.reboot-codes.com";
      COOKIE_SECURE = "true";
      REDIRECT_DOMAINS = "www.reboot-codes.com";
    };
  };
}
