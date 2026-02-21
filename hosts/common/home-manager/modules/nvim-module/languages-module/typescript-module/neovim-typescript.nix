{ pkgs, utility, ... }:
{
  imports = [
    ./javascript-module/neovim-javascript.nix
  ];
  programs.neovim = {
    extraPackages = with pkgs; [
      nodePackages.typescript-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-typescript
          ]
        ))
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-typescript.lua;
      }
    ];
  };

  home = {
    packages = with pkgs; [
      nodePackages.typescript
    ];
    file.".config/nvim/lsp/ts_ls.lua".source = ./lspconfig-typescript.lua;
  };
}
