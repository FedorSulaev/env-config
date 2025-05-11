{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    env-secrets = {
      url = "git+ssh://git@github.com/FedorSulaev/env-secrets.git";
      inputs = { };
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
    let
      overlays = [
        (final: prev: {
          nodejs_20_fixed = prev.nodejs_20.overrideAttrs (_: {
            doCheck = false;
          });
          nodePackages = prev.nodePackages.override {
            nodejs = final.nodejs_20_fixed;
          };
          nodejs-slim_20 = final.nodejs_20_fixed;
          nodejs_20 = final.nodejs_20_fixed;
          folly_fixed = prev.folly.overrideAttrs (_: {
            doCheck = false;
          });
          folly = final.folly_fixed;
        })
      ];
      pkgs-mac-arm = import nixpkgs {
        system = "aarch64-darwin";
        overlays = overlays;
        # Required as workaround for failing tests when building nodejs-slim_20
        # nodejs-slim_20 is not officially supported but pulled as dependency
        # tests are failing on Macos aarch64
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
          ./home-manager/mac-os-personal.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
      homeConfigurations.DevDsk = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs-linux-x86;
        modules = [
          ./home-manager/dev-dsk.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
      darwinConfigurations = {
        "MacBook-Pro-Fedor" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = pkgs-mac-arm;
          modules = [
            ./hosts/macbook-personal/macbook-personal.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.fedorsulaev = ./home-manager/mac-os-personal.nix;
              };
            }
          ];
          inputs = { inherit inputs; };
        };
      };
      nixosConfigurations = {
        "iso" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgs-linux-x86;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/iso/iso.nix ];
        };
      };
    };
}
