{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      nodePackages.dockerfile-language-server-nodejs
      hadolint
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-dockerfile
          ]
        ))
      nvim-cmp
    ];
  };

  home.file.".config/nvim/lsp/dockerls.lua".source = ./lspconfig-dockerfile.lua;
}
