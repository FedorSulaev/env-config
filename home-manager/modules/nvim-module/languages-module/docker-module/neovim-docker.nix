{ pkgs, utility, ... }:
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
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig-dockerfile.lua;
      }
    ];
  };
}
