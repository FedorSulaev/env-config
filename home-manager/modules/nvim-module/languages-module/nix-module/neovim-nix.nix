{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      nixd
      nixpkgs-fmt
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-nix
          ]
        ))
      nvim-cmp
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig-nix.lua;
      }
    ];
  };

  home.file.".config/nvim/after/ftplugin/nix.lua".source = ./nix.lua;
}
