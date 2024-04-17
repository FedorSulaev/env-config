{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    homeConfigurations = {
      MacBook-Pro-Fedor = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "aarch64-darwin";
	      };
	      modules = [
	        ./nixpkgs/home-manager/mac-os-personal.nix
	      ];
      };
    };
  };
}
