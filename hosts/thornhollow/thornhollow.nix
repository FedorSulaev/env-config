{ inputs, config, pkgs, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
  ];

  hostSpec = {
    inherit (inputs.env-secrets.thornhollow) hostName username authorizedKeys hashedPassword rootHashedPassword;
    inherit (inputs.env-secrets) networking;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAuthentication = true;
      };
    };
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "_" = {
          default = true;
          locations."/" = { return = "444"; };
        };
        "${config.hostSpec.networking.dns.riverfall.actual.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${config.hostSpec.networking.dns.riverfall.actual.target}";
            proxyWebsockets = true;

            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
        "obsistant.com" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            return = "404";
          };
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.hostSpec.networking.dns.email;
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };
  };

  networking = {
    hostName = config.hostSpec.hostName;
    useNetworkd = true;
    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = config.hostSpec.networking.hosts.thornhollow.address;
        prefixLength = config.hostSpec.networking.hosts.thornhollow.prefixLength;
      }];
    };
    defaultGateway = {
      address = config.hostSpec.networking.hosts.thornhollow.gatewayAddress;
      interface = "enp1s0";
    };
    nameservers = config.hostSpec.networking.hosts.thornhollow.nameservers;
    firewall.allowedTCPPorts = [ 80 443 ];
  };


  systemd.services.update-ddns = {
    description = "DDNS Update";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.hostSpec.networking.dns.secretsFile;
      StateDirectory = "update-ddns";
      ReadWritePaths = [ "/var/lib/update-ddns" ];
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };

    script = ''
      set -euo pipefail

      LAST="/var/lib/update-ddns/last_ip"

      IP="$(${pkgs.curl}/bin/curl -sS \
        -H "Content-Type: application/json" \
        -d "{\"apikey\":\"''${API_KEY}\",\"secretapikey\":\"''${SECRET_API_KEY}\"}" \
        "https://api.porkbun.com/api/json/v3/ping" | ${pkgs.jq}/bin/jq -r '.yourIp')"

      if [ -z "$IP" ] || [ "$IP" = "null" ]; then
        echo "Failed to obtain public IP from ping"
        exit 1
      fi

      if [ -f "$LAST" ] && [ "$(cat "$LAST")" = "$IP" ]; then
        echo "IP unchanged ($IP), skipping"
        exit 0
      fi

      ZONE="''${ZONE}"

      RECORDS_JSON="$(${pkgs.curl}/bin/curl -sS \
        -H "Content-Type: application/json" \
        -d "{\"apikey\":\"''${API_KEY}\",\"secretapikey\":\"''${SECRET_API_KEY}\"}" \
        "https://api.porkbun.com/api/json/v3/dns/retrieve/$ZONE")"
      echo "A records returned for $ZONE:"
      echo "$RECORDS_JSON" | ${pkgs.jq}/bin/jq -r \
        '.records[] | select(.type=="A") | "\(.id)\t\(.name)\t\(.content)\tTTL=\(.ttl)"'


      if [ "$(echo "$RECORDS_JSON" | ${pkgs.jq}/bin/jq -r '.status')" != "SUCCESS" ]; then
        echo "DNS retrieve failed: $RECORDS_JSON"
        exit 1
      fi

      APEX_ID="$(echo "$RECORDS_JSON" | ${pkgs.jq}/bin/jq -r --arg z "$ZONE" '
        .records[]
        | select(.type=="A")
        | select(
          (.name | rtrimstr(".")) == $z
          or (.name | rtrimstr(".")) == ($z + "." + $z)
        )
        | .id
      ' | head -n1)"

      APEX_NAME="$(echo "$RECORDS_JSON" | ${pkgs.jq}/bin/jq -r --arg z "$ZONE" '
        .records[]
        | select(.type=="A")
        | select(
          (.name | rtrimstr(".")) == $z
          or (.name | rtrimstr(".")) == ($z + "." + $z)
        )
        | .name
      ' | head -n1)"

      if [ -z "$APEX_ID" ] || [ -z "$APEX_NAME" ] || [ "$APEX_ID" = "null" ] || [ "$APEX_NAME" = "null" ]; then
        echo "Could not find apex A record for $ZONE"
        exit 1
      fi

      UPDATE_JSON="$(${pkgs.curl}/bin/curl -sS -H "Content-Type: application/json" \
        -d "{\"apikey\":\"''${API_KEY}\",\"secretapikey\":\"''${SECRET_API_KEY}\",\"name\":\"$APEX_NAME\",\"type\":\"A\",\"content\":\"$IP\",\"ttl\":\"600\"}" \
      "https://api.porkbun.com/api/json/v3/dns/edit/$ZONE/$APEX_ID")"


      if [ "$(echo "$UPDATE_JSON" | ${pkgs.jq}/bin/jq -r '.status')" != "SUCCESS" ]; then
        echo "DNS edit failed: $UPDATE_JSON"
        exit 1
      fi

      echo "$IP" > "$LAST"
      echo "Updated $APEX_NAME -> $IP"
    '';
  };

  systemd.timers.update-ddns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "10min";
      RandomizedDelaySec = "60s";
      Persistent = true;
    };
  };

  users = {
    users.fedorsulaev = {
      isNormalUser = true;
      name = config.hostSpec.username;
      home = config.hostSpec.home;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = config.hostSpec.authorizedKeys;
      hashedPassword = config.hostSpec.hashedPassword;
    };
    users.root = {
      hashedPassword = config.hostSpec.rootHashedPassword;
    };
  };

  nix.settings = {
    trusted-users = [ "root" config.hostSpec.username ];
  };

  time.timeZone = "Europe/Bucharest";

  environment.systemPackages = with pkgs; [
    vim
    cloud-utils
    jq
    openssl
    ripgrep
  ];

  system.stateVersion = "25.11";
}
