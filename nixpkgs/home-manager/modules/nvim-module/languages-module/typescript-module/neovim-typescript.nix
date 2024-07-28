{ pkgs, ... }:
{
  imports = [
    ./javascript-module/neovim-javascript.nix
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-typescript
          ]
        ))
    ];
  };
}
