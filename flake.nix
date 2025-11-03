{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
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
        (final: prev: {
          python313 = prev.python313.override {
            packageOverrides = pyFinal: pyPrev: {
              # tests fail on 1.32.1
              cfn-lint = pyPrev.cfn-lint.overridePythonAttrs (_: {
                doCheck = false;
              });
            };
          };
        })
      ];
      pkgs-mac-arm = import nixpkgs {
        system = "aarch64-darwin";
        overlays = overlays;
      };
      pkgs-linux-arm = import nixpkgs {
        system = "aarch64-linux";
        overlays = overlays;
      };
      pkgs-linux-x86 = import nixpkgs {
        system = "x86_64-linux";
        overlays = overlays;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations.Docker-Nix-Test = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs-linux-arm;
        modules = [
          ./home-manager/breezora.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
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
        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgs-linux-x86;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/iso/iso.nix ];
        };
        stonebark = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgs-linux-x86;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            inputs.disko.nixosModules.disko
            inputs.NixVirt.nixosModules.default
            ./hosts/common/disks/host-disk.nix
            ./hosts/stonebark/stonebark.nix
          ];
        };
        riverfall = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgs-linux-x86;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/riverfall/riverfall.nix
            ./hosts/riverfall/riverfall-qcow.nix
          ];
        };
      };
      packages.x86_64-linux.riverfall-qcow2 =
        let
          system = "x86_64-linux";
          pkgs = pkgs-linux-x86;
          lib = pkgs.lib;
          nixosConfig = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = [
              ./hosts/riverfall/riverfall.nix
              ./hosts/riverfall/riverfall-qcow.nix
            ];
          };
        in
        import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
          inherit pkgs lib;
          name = "riverfall";
          format = "qcow2";
          diskSize = 8192; # MB
          config = nixosConfig.config;
        };
    };
}
