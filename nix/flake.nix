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
      pkgs-mac-arm = import nixpkgs {
        system = "aarch64-darwin";
      };
      pkgs-linux-arm = import nixpkgs {
        system = "aarch64-linux";
      };
      pkgs-linux-x86 = import nixpkgs {
        system = "x86_64-linux";
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
