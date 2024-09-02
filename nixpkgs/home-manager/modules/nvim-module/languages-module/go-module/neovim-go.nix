{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      gopls
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-go
          ]
        ))
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-go.lua;
      }
      nvim-cmp
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig-go.lua;
      }
    ];
  };
}
