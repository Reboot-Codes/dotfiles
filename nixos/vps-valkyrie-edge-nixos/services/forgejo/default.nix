{ pkgs, ... }: {
  services = {
    caddy.virtualHosts = {
      "git.reboot-codes.com" = {
        extraConfig = ''
          import default_robots

          # Bypass Coraza WAF and Anubis rules for Git smart HTTP protocol endpoints
          @git_ops {
            path_regexp git \.git/(info/refs|git-upload-pack|git-receive-pack)$
          }

          handle @git_ops {
            reverse_proxy http://127.0.0.1:3000 {
              import cloudflare_trusted
            }
          }

          # Bypass Anubis rules for API endpoints
          @api_ops {
            # Forgejo API and webhooks
            path /api/*
            path /v1/*

            # Forgejo

            # Forgejo Actions runner polling / gRPC / dispatch
            path /api/actions/*
            path /login/oauth/*

            # SSH key discovery
            path /.well-known/*

            # Assets
            path /assets/*
            path /avatars/*
            path /favicon.ico
            path /robots.txt
            path *.css
            path *.js
            path *.svg
            path *.png
            path *.woff2
          }

          handle @api_ops {
            import waf

            reverse_proxy http://127.0.0.1:3000 {
              import cloudflare_trusted
            }
          }

          # Everything else (web UI, API, etc.) runs through Coraza
          handle {
            import waf

            reverse_proxy http://127.0.0.1:8924 {
              import cloudflare_trusted
            }
          }
        '';
      };

      "badges.reboot-codes.com" = {
        extraConfig = ''
          import waf
          import default_robots

          reverse_proxy 127.0.0.1:3001 {
            import cloudflare_trusted
          }
        '';
      };
    };

    forgejo = {
      enable = true;
      database.type = "sqlite3";

      settings = {
        server = {
          DOMAIN = "git.reboot-codes.com";
          ROOT_URL = "https://git.reboot-codes.com/";
          HTTP_PORT = 3000;
          HTTP_ADDR = "127.0.0.1";
          DISABLE_SSH = true;
        };

        service = {
          DISABLE_REGISTRATION = true; # Invite only.
        };

        ui = {
          THEMES = "forgejo-auto,forgejo-light,forgejo-dark,recorp";
          DEFAULT_THEME = "recorp";
        };
      };
    };
  };

  systemd = {
    tmpfiles.rules = [
      "d /var/lib/forgejo-runner 0750 root root -"

      "d /var/lib/forgejo/custom/public/assets/css 0775 forgejo forgejo -"
      "d /var/lib/forgejo/custom/templates 0775 forgejo forgejo -"
      "L+ /var/lib/forgejo/custom/public/assets/css/theme-recorp.css - forgejo forgejo - ${./theme-recorp.css}"
      "L+ /var/lib/forgejo/custom/templates/home.tmpl - forgejo forgejo - ${./templates/home.tmpl}"

      "d /var/www 0755 caddy caddy -   -"
      "d /var/www/reboot-codes.com 0755 caddy caddy -   -"
    ];

    services = {
      forgejo-runner = {
        description = "Forgejo Actions Runner Daemon";
        after = [ "network-online.target" "podman.socket" ];
        wants = [ "network-online.target" "podman.socket" ];
        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [
          forgejo-runner
          podman
          git
          bash
          busybox
        ];

        serviceConfig = {
          Type = "simple";
          User = "root";
          WorkingDirectory = "/opt/forgejo-runner/workspace";
          ExecStart = "${pkgs.forgejo-runner}/bin/forgejo-runner daemon --config /opt/forgejo-runner/config.yaml";
          Restart = "always";
          RestartSec = "5s";

          # Hardening
          LimitNOFILE = 65535;
        };
      };
    };
  };

  virtualisation.oci-containers.containers = {
    anubis-forgejo = {
      image = "ghcr.io/techarohq/anubis:latest";
      autoStart = true;

      extraOptions = [ "--network=host" ];

      environment = {
        BIND = "0.0.0.0:8924";
        TARGET = "http://127.0.0.1:3000";
        COOKIE_DOMAIN = "git.reboot-codes.com";
        COOKIE_SECURE = "true";
      };
    };

    "markdown-shields" = {
      image = "docker.io/shieldsio/shields:next";
      autoStart = true;

      ports = [
        "127.0.0.1:3001:80"
      ];

      environment = {
        BASE_URL = "https://badges.reboot-codes.com";
      };
    };
  };
}
