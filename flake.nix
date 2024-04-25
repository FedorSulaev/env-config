{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nvim plugins from GitHub
    mason-nvim-dap.url = https://github.com/jay-babu/mason-nvim-dap.nvim;
    mason-nvim-dap.flake = false;
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      homeConfigurations.MacBook-Pro-Fedor = inputs.home-manager.lib.homeManagerConfiguration {
	inherit pkgs;
	modules = [ ./nixpkgs/home-manager/mac-os-personal.nix ];
	extraSpecialArgs = { inherit inputs; };
      };
    };
}
