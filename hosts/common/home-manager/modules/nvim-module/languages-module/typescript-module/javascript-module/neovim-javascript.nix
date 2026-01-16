{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      nodePackages.prettier
    ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-javascript.lua;
      }
    ];
  };
  home.packages = with pkgs; [
    nodejs-slim_20
  ];
}
