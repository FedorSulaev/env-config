{ inputs, config, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
  ];

  hostSpec = {
    username = inputs.env-secrets.breezora.username;
    hostName = inputs.env-secrets.breezora.hostName;
  };

  nix.settings.experimental-features = "nix-command flakes";
  nix.buildMachines = [{
    system = "x86_64-linux";
    protocol = "ssh-ng";
    maxJobs = 4;
    speedFactor = 1;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  }];
  nix.distributedBuilds = true;
  users.users.fedorsulaev = {
    name = config.hostSpec.username;
    home = config.hostSpec.home;
  };
  system.stateVersion = 5;
}
