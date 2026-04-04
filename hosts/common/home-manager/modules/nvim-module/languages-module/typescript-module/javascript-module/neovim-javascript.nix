{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      prettier
    ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = conform-nvim;
        type = "viml";
        config = utility.toLuaFile ./conform-formatters-javascript.lua;
      }
    ];
  };
  home.packages = with pkgs; [
    nodejs_24
  ];
}
