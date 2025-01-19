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
      nvim-cmp
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig-go.lua;
      }
    ];
  };
}
