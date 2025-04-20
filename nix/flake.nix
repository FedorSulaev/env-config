{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }@inputs:
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
      };
    in
    {
      homeConfigurations.MacBook-Pro-Fedor = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs-mac-arm;
        modules = [
          ./../nixpkgs/home-manager/mac-os-personal.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
      homeConfigurations.Docker-Nix-Test = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs-linux-arm;
        modules = [
          ./../nixpkgs/home-manager/mac-os-personal.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
      homeConfigurations.DevDsk = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs-linux-x86;
        modules = [
          ./../nixpkgs/home-manager/dev-dsk.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
