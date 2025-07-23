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
    ];
  };

  home.file.".config/nvim/lsp/gopls.lua".source = ./lspconfig-go.lua;
}
