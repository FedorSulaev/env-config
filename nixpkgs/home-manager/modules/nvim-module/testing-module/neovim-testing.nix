{ pkgs, utility, ... }:
{
  imports = [
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = vim-test;
        config = utility.toLuaFile ./vim-test.lua;
      }
    ];
  };
}

