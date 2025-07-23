{ pkgs, utility, ... }:
{
  imports = [
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform.lua;
      }
    ];
  };
}
