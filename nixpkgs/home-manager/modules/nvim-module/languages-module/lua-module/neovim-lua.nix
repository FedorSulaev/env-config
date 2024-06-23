{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      lua54Packages.luarocks
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-lua
            tree-sitter-luadoc
          ]
        )
      )
      {
        plugin = neodev-nvim;
        config = utility.toLuaFile ./neodev.lua;
      }
    ];
  };
}
