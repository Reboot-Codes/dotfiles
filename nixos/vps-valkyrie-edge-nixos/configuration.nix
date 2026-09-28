{ lib, ... }: {
  # Headless server: disable desktop services from common
  services.avahi.enable = false;
  services.tor.enable = false;
  hardware.flipperzero.enable = false;
  environment.sessionVariables.QT_QPA_PLATFORM = lib.mkForce "";

  security = {
    audit = {
      enable = true;
      backlogLimit = 8192;
      failureMode = "silent";

      # Custom audit rules monitoring sensitive actions
      rules = [
        # Monitor process executions
        "-a always,exit -F arch=b64 -S execve -k exec_log"
        # Monitor changes to user/group databases
        "-w /etc/passwd -p wa -k identity_changes"
        "-w /etc/shadow -p wa -k identity_changes"
        # Monitor changes to SSH keys
        "-w /root/.ssh -p wa -k root_ssh"
      ];
    };
  };

  services = {
    tailscale.enable = true;

    openssh = {
      settings.PermitRootLogin = "prohibit-password";
    };

    caddy = {
      enable = true;
      # Point 'package' to your custom Caddy package if compiled with Coraza WAF
      extraConfig = ''
        # Main Static Site
        #reboot-codes.com {
        #  root * /var/www/reboot-codes.com
        #  file_server
        #}

        # Forgejo
        git.reboot-codes.com {
          reverse_proxy 127.0.0.1:3000
        }
      '';
    };

    prometheus.exporters.node = {
      enable = true;
      listenAddress = "100.92.214.3"; # Bind EXCLUSIVELY to Tailscale IP
      port = 9100;
      enabledCollectors = [ "systemd" "network" "cpu" "meminfo" "diskstats" ];
    };

    osquery = {
      enable = true;
      flags = {
        # NixOS creates /run/osquery runtime directory
        extensions_socket = "/run/osquery/osquery.em";
      };
      settings = {
        schedule = {
          listening_ports = {
            query = "SELECT pid, port, protocol, address FROM listening_ports;";
            interval = 300;
          };
          logged_in_users = {
            query = "SELECT user, tty, host, time FROM logged_in_users;";
            interval = 60;
          };
        };
      };
    };

    vector = {
      enable = true;
      journaldAccess = true;
      settings = {
        sources = {
          journal_logs = {
            type = "journald";
            exclude_units = [ "vector.service" ];
          };

          osquery_results = {
            type = "file";
            include = [ "/var/log/osquery/osqueryd.results.log" ];
            read_from = "end";
          };
        };

        transforms = {
          # Optional: Parse osquery JSON string into structured fields
          parse_osquery = {
            type = "remap";
            inputs = [ "osquery_results" ];
            source = ''
              parsed, err = parse_json(.message)
              if err == null {
                .osquery = parsed
              }
            '';
          };
        };

        sinks = {
          homelab_loki = {
            type = "loki";
            inputs = [ "journal_logs" "parse_osquery" ];
            endpoint = "http://zimaos.tail90c5.ts.net:3100";
            encoding.codec = "json";
            labels = {
              host = "vps";
              env = "production";
              # Dynamic labels pulled from journald fields
              unit = "{{ _SYSTEMD_UNIT }}";
            };
          };
        };
      };
    };

    forgejo = {
      enable = true;
      database.type = "sqlite3"; # Ultra lightweight; low RAM consumption
      settings = {
        server = {
          DOMAIN = "git.reboot-codes.com";
          ROOT_URL = "https://git.reboot-codes.com/";
          HTTP_PORT = 3000;
          HTTP_ADDR = "127.0.0.1";
        };
        service = {
          DISABLE_REGISTRATION = true; # Invite only.
        };
      };
    };

    # Logs get big AF and contabo only gives us like 100 gigs at this tier.
    journald.extraConfig = ''
      SystemMaxUse=2G
      SystemKeepFree=5G
      MaxRetentionSec=1month
    '';
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Declaratively run lithium.
    #oci-containers.containers = {
    #  lithium = {
    #    image = "denoland/deno:alpine"; # or your custom registry image
    #    cmd = [ "run" "--allow-net" "--allow-env" "main.ts" ];
    #    volumes = [
    #      "/var/lib/discord-bot:/app"
    #    ];
    #    workdir = "/app";
    #    environmentFiles = [
    #      "/var/secrets/discord-bot.env"
    #    ];
    #    autoStart = true;
    #  };
    #};
  };
}
