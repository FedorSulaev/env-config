{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = gruvbox-nvim;
        type = "viml";
        config = utility.toLuaFile ./theme.lua;
      }
    ];
  };
}
