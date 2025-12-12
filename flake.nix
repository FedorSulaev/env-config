{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    env-secrets = {
      url = "git+ssh://git@github.com-env-secrets/FedorSulaev/env-secrets.git";
      inputs = { };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
    let
      overlays = [
        (final: prev: { })
      ];

      mkPkgs = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      pkgs-mac-arm = mkPkgs "aarch64-darwin";
      pkgs-linux-x86 = mkPkgs "x86_64-linux";

      mkNixos = modules: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = pkgs-linux-x86;
        specialArgs = { inherit inputs; };
        inherit modules;
      };

      vmDefs = {
        riverfall = {
          modules = [
            ./hosts/riverfall/riverfall.nix
            ./hosts/riverfall/riverfall-qcow.nix
          ];
          diskSize = 40960;
          imageName = "riverfall-qcow2";
        };
        sunpeak = {
          modules = [
            ./hosts/sunpeak/sunpeak.nix
            ./hosts/sunpeak/sunpeak-qcow.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit inputs; };
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                users."${inputs.env-secrets.sunpeak.username}" =
                  ./hosts/sunpeak/sunpeak-home.nix;
              };
            }
          ];
          diskSize = 40960;
          imageName = "sunpeak-qcow2";
        };
      };
      mkVMImage = { imageName, modules, diskSize }:
        let
          vmConfig = mkNixos modules;
        in
        import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
          pkgs = pkgs-linux-x86;
          lib = pkgs-linux-x86.lib;
          inherit diskSize;
          name = imageName;
          format = "qcow2";
          config = vmConfig.config;
        };
    in
    {
      homeConfigurations.DevDsk = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs-linux-x86;
        modules = [
          ./hosts/dev-dsk/dev-dsk-home-manager.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };

      darwinConfigurations = {
        breezora = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = pkgs-mac-arm;
          modules = [
            ./hosts/breezora/breezora.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.fedorsulaev = ./hosts/breezora/breezora-home-manager.nix;
              };
            }
          ];
          inputs = inputs;
        };
      };

      nixosConfigurations = {
        iso = mkNixos [ ./hosts/iso/iso.nix ];
        stonebark = mkNixos [
          inputs.disko.nixosModules.disko
          inputs.NixVirt.nixosModules.default
          ./hosts/common/disks/host-disk.nix
          ./hosts/stonebark/stonebark.nix
        ];
      }
      // nixpkgs.lib.mapAttrs (_name: def: mkNixos def.modules) vmDefs;

      packages.x86_64-linux = nixpkgs.lib.mapAttrs'
        (vmName: def:
          let
            imageName = def.imageName or "${vmName}-qcow2";
          in
          {
            name = imageName;
            value = mkVMImage {
              inherit imageName;
              inherit (def) modules diskSize;
            };
          }
        )
        vmDefs;
    };
}
