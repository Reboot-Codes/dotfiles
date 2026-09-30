{ ... }: {
  services = {
    prometheus.exporters.node = {
      enable = true;
      listenAddress = "100.92.214.3"; # Bind EXCLUSIVELY to Tailscale IP
      port = 9100;
      enabledCollectors = [ "systemd" "netdev" "cpu" "meminfo" "diskstats" ];
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
          parse_osquery = {
            type = "remap";
            inputs = [ "osquery_results" ];
            source = ''
              parsed, err = parse_json(.message)
              if err == null {
                .osquery = parsed
              }
              .service_name = "osquery"
              .unit = "osquery.service"
            '';
          };

          normalize_journal = {
            type = "remap";
            inputs = [ "journal_logs" ];
            source = ''
              # Strip trailing .service for cleaner service_name display, fallback to syslog identifier or "unknown"
              raw_unit = string(._SYSTEMD_UNIT) ?? string(.SYSLOG_IDENTIFIER) ?? "unknown"
              .unit = raw_unit
              .service_name = replace(raw_unit, r'\.service$', "")
            '';
          };
        };

        sinks = {
          homelab_loki = {
            type = "loki";
            inputs = [ "normalize_journal" "parse_osquery" ];
            endpoint = "http://zimaos.tail90c5.ts.net:3100";
            dangerously_allow_unconfined_template_resolution = true;
            encoding.codec = "json";
            labels = {
              host = "vps-valkyre-edge-nixos";
              env = "production";
              unit = "{{ unit }}";
              service_name = "{{ service_name }}";
            };
          };
        };
      };
    };
  };
}
