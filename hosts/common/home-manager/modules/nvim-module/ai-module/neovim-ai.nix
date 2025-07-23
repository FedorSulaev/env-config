{ pkgs, utility, ... }:
{
  imports = [ ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = avante-nvim;
        config = utility.toLuaFile ./avante-nvim.lua;
      }
    ];
  };
}
