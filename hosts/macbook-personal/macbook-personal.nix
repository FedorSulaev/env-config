{ pkgs, ... }:
{
  nix.settings.experimental-features = "nix-command flakes";
  nix.buildMachines = [{
    system = "x86_64-linux";
    protocol = "ssh-ng";
    maxJobs = 4;
    speedFactor = 1;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  }];
  nix.distributedBuilds = true;
  system.stateVersion = 5;
}
