{ pkgs, ... }: {
  services = {
    caddy = {
      extraConfig = ''
        (waf_forgejo) {
          coraza_waf {
            load_owasp_crs
            directives `
              Include @coraza.conf-recommended
              # Disable response body inspection: git commit diffs, blob views, and file contents
              # contain arbitrary code (SQL, PHP, command lines, stack traces) which trigger false-positive
              # outbound leakage rules (950xxx-954xxx), and diffs often exceed SecResponseBodyLimit.
              SecResponseBodyAccess Off

              Include @crs-setup.conf.example

              # Remove .com from restricted extensions so website repos and .com pages are accessible
              SecAction \
                "id:10013,\
                phase:1,\
                pass,\
                nolog,\
                setvar:'tx.restricted_extensions=.ani/ .asa/ .asax/ .ascx/ .back/ .backup/ .bak/ .bck/ .bk/ .bkp/ .bat/ .cdx/ .cer/ .cfg/ .cmd/ .cnf/ .compositefont/ .config/ .conf/ .copy/ .crt/ .cs/ .csproj/ .csr/ .dat/ .db/ .dbf/ .dist/ .dll/ .dos/ .dpkg-dist/ .drv/ .gadget/ .hta/ .htr/ .htw/ .ida/ .idc/ .idq/ .inc/ .inf/ .ini/ .jks/ .jse/ .key/ .licx/ .lnk/ .log/ .mdb/ .msc/ .ocx/ .old/ .pass/ .pdb/ .pfx/ .pif/ .pem/ .pol/ .prf/ .printer/ .pwd/ .rdb/ .rdp/ .reg/ .resources/ .resx/ .sav/ .save/ .scr/ .sct/ .sh/ .shs/ .sql/ .sqlite/ .sqlite3/ .swap/ .swo/ .swp/ .sys/ .temp/ .tfstate/ .tlb/ .tmp/ .vb/ .vbe/ .vbs/ .vbproj/ .vsdisco/ .vxd/ .webinfo/ .ws/ .wsc/ .wsf/ .wsh/ .xsd/ .xsx/'"

              SecRule REQUEST_URI "@rx ^/\.within\.website/" \
                "id:10009,\
                phase:1,\
                pass,\
                nolog,\
                ctl:ruleRemoveById=930120,\
                ctl:ruleRemoveById=930130,\
                ctl:ruleRemoveById=920440"

              # Allow git-related views (src, raw, blame, commit, diffs, compare, pulls, archive, releases)
              SecRule REQUEST_URI "@rx /(src|raw|blame|commits?|compare|pulls|archive|releases|issues|wiki|api/v1/repos/[^/]+/[^/]+/(raw|contents))/" \
                "id:10010,phase:1,pass,nolog,ctl:ruleRemoveById=920440,ctl:ruleRemoveById=930130,ctl:ruleRemoveById=920350"

              # Allow repo root pages even if named with an extension (e.g. repo.com, repo.sh)
              SecRule REQUEST_URI "@rx ^/[^/]+/[^/]+/?$" \
                "id:10014,phase:1,pass,nolog,ctl:ruleRemoveById=920440,ctl:ruleRemoveById=930130"

              SecRule REQUEST_URI "@rx /(raw|archive)/" \
                "id:10011,phase:1,pass,nolog,ctl:ruleRemoveById=932100,ctl:ruleRemoveById=932150"

              SecRule REQUEST_HEADERS:Content-Type "@rx ^application/x-git-(upload|receive)-pack" \
                "id:10012,\
                phase:1,\
                pass,\
                nolog,\
                ctl:ruleRemoveById=920420"

              Include @owasp_crs/*.conf
              SecRuleEngine On
            `
          }
        }
      '';

      virtualHosts = {
        "git.reboot-codes.com" = {
          extraConfig = ''
            import default_robots

            # Bypass Coraza WAF and Anubis rules for Git smart HTTP protocol endpoints
            @git_ops {
              path_regexp git (^|/)(info/refs|git-upload-pack|git-receive-pack)$
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
              path */badge.svg
              path */badge.svg*

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
              import waf_forgejo

              reverse_proxy http://127.0.0.1:3000 {
                import cloudflare_trusted
              }
            }

            handle {
              import waf_forgejo

              reverse_proxy http://127.0.0.1:8924 {
                import cloudflare_trusted
                header_up X-Real-IP {client_ip}
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
    };

    forgejo = {
      enable = true;
      database.type = "sqlite3";

      settings = {
        DEFAULT = {
          APP_NAME = "ReCorp Forgejo";
          APP_SLOGAN = "In tiG we Fuck.";
        };

        server = {
          DOMAIN = "git.reboot-codes.com";
          ROOT_URL = "https://git.reboot-codes.com/";
          HTTP_PORT = 3000;
          HTTP_ADDR = "127.0.0.1";
          DISABLE_SSH = true;
        };

        badges = {
          ENABLED = true;
          GENERATOR_URL_TEMPLATE = "https://badges.reboot-codes.com/badge/{{.label}}-{{.text}}-{{.color}}";
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
        after = [
          "network-online.target"
          "podman.socket"
          "forgejo.service"
        ];
        wants = [
          "network-online.target"
          "podman.socket"
          "forgejo.service"
        ];
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
        OG_PASSTHROUGH = "true";
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
