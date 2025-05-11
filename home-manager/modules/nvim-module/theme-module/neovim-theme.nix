{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = gruvbox-nvim;
        config = utility.toLuaFile ./theme.lua;
      }
    ];
  };
}
