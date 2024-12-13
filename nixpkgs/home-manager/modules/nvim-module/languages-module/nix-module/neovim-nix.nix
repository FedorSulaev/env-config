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
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-nix.lua;
      }
      nvim-cmp
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig-nix.lua;
      }
    ];
  };
}
