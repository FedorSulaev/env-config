{ inputs, config, pkgs, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
  ];

  hostSpec = {
    inherit (inputs.env-secrets.riverfall) hostName username authorizedKeys hashedPassword rootHashedPassword;
    inherit (inputs.env-secrets) networking;
  };

  sops = {
    defaultSopsFile = "${builtins.toString inputs.env-secrets + "/sops"}/${config.hostSpec.hostName}.enc.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."nextcloud_env" = { };
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
  };

  networking = {
    hostName = config.hostSpec.hostName;
    useNetworkd = true;
    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = config.hostSpec.networking.hosts.riverfall.address;
        prefixLength = config.hostSpec.networking.hosts.riverfall.prefixLength;
      }];
    };
    defaultGateway = {
      address = config.hostSpec.networking.hosts.riverfall.gatewayAddress;
      interface = "enp1s0";
    };
    nameservers = config.hostSpec.networking.hosts.stonebark.nameservers;
    firewall.allowedTCPPorts = [
      5006 # ActualBudget
      5007 # Nextcloud
    ];
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
  ];

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "--filter=until=24h"
          "--filter=label!=important"
        ];
      };
    };
    oci-containers.backend = "podman";
    oci-containers.containers = {
      actualBudget = {
        image = "docker.io/actualbudget/actual-server:26.2.0-alpine";
        autoStart = true;
        environment = {
          # Environment variables for the Actual Server
          # ACTUAL_HTTPS_KEY = "/data/selfhost.key";
          # ACTUAL_HTTPS_CERT = "/data/selfhost.crt";
          # Uncomment and customize additional options if needed
          # ACTUAL_PORT = "5006";
          # ACTUAL_UPLOAD_FILE_SYNC_SIZE_LIMIT_MB = "20";
          # ACTUAL_UPLOAD_SYNC_ENCRYPTED_FILE_SYNC_SIZE_LIMIT_MB = "50";
          # ACTUAL_UPLOAD_FILE_SIZE_LIMIT_MB = "20";
        };
        ports = [ "5006:5006" ];
        volumes = [
          "/var/lib/actualbudget:/data"
        ];
      };

      nextcloud-db = {
        image = "docker.io/library/postgres:17-alpine";
        autoStart = true;
        environment = {
          POSTGRES_DB = "nextcloud";
        };
        environmentFiles = [ config.sops.secrets."nextcloud_env".path ];
        volumes = [
          "/var/lib/nextcloud/postgres:/var/lib/postgresql/data"
        ];
      };

      nextcloud-redis = {
        image = "docker.io/library/redis:7-alpine";
        autoStart = true;
        cmd = [ "redis-server" "--save" "" "--appendonly" "no" ];
      };

      nextcloud = {
        image = "docker.io/library/nextcloud:32";
        autoStart = true;
        dependsOn = [ "nextcloud-db" "nextcloud-redis" ];
        environment = {
          POSTGRES_HOST = "nextcloud-db";
          POSTGRES_DB = "nextcloud";
          REDIS_HOST = "nextcloud-redis";
        };
        environmentFiles = [ config.sops.secrets."nextcloud_env".path ];
        ports = [ "5007:80" ];
        volumes = [
          "/var/lib/nextcloud/html:/var/www/html"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/actualbudget 0750 1000 1000 -"
    "d /var/lib/nextcloud 0750 root root -"
    "d /var/lib/nextcloud/html 0750 root root -"
    "d /var/lib/nextcloud/postgres 0750 root root -"
  ];

  system.stateVersion = "25.05";
}
