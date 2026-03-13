{ inputs, ... }:
let
  helpers = import ./shared/lib.nix { inherit inputs; };

  vmDefs = {
    riverfall = {
      modules = [
        inputs.sops-nix.nixosModules.sops
        ../hosts/riverfall/riverfall.nix
        ../hosts/riverfall/riverfall-qcow.nix
      ];
      diskSize = 40960;
      imageName = "riverfall-qcow2";
    };
  };

  mkVMImage = { imageName, modules, diskSize }:
    let
      vmConfig = helpers.mkNixos modules;
    in
    import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix" {
      pkgs = helpers.pkgs-linux-x86;
      lib = helpers.pkgs-linux-x86.lib;
      inherit diskSize;
      name = imageName;
      format = "qcow2";
      config = vmConfig.config;
    };
in
{
  perSystem = { system, ... }: {
    packages =
      if system == "x86_64-linux" then
        inputs.nixpkgs.lib.mapAttrs'
          (vmName: def: {
            name = def.imageName or "${vmName}-qcow2";
            value = mkVMImage {
              imageName = def.imageName or "${vmName}-qcow2";
              inherit (def) modules diskSize;
            };
          })
          vmDefs
      else
        { };
  };

  flake = {
    homeConfigurations.DevDsk =
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = helpers.pkgs-linux-x86;
        modules = [
          ../hosts/dev-dsk/dev-dsk-home-manager.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };

    darwinConfigurations = {
      breezora = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = helpers.pkgs-mac-arm;
        modules = [
          ../hosts/breezora/breezora.nix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.fedorsulaev =
                ../hosts/breezora/breezora-home-manager.nix;
            };
          }
        ];
        inputs = inputs;
      };
    };

    nixosConfigurations =
      {
        iso = helpers.mkNixos [ ../hosts/iso/iso.nix ];
        stonebark = helpers.mkNixos [
          inputs.disko.nixosModules.disko
          inputs.NixVirt.nixosModules.default
          inputs.sops-nix.nixosModules.sops
          ../hosts/common/disks/host-disk.nix
          ../hosts/stonebark/stonebark.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users."${inputs.env-secrets.stonebark.username}" =
                ../hosts/stonebark/stonebark-home.nix;
            };
          }
        ];
      }
      // inputs.nixpkgs.lib.mapAttrs (_name: def: helpers.mkNixos def.modules) vmDefs;
  };
}
