{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      dockerfile-language-server
      hadolint
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-dockerfile
          ]
        ))
    ];
  };

  home.file.".config/nvim/lsp/dockerls.lua".source = ./lspconfig-dockerfile.lua;
}
