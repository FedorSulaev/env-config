{ pkgs, utility, ... }:
{
  imports = [ ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = avante-nvim;
        type = "viml";
        config = utility.toLuaFile ./avante-nvim.lua;
      }
    ];
  };
}
