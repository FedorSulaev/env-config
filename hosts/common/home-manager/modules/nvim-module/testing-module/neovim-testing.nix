{ pkgs, utility, ... }:
{
  imports = [
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = vim-test;
        type = "viml";
        config = utility.toLuaFile ./vim-test.lua;
      }
    ];
  };
}

