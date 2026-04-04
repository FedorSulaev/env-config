{ pkgs, utility, ... }:
{
  imports = [
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = conform-nvim;
        type = "viml";
        config = utility.toLuaFile ./conform.lua;
      }
    ];
  };
}
