{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      nodejs_20
    ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-javascript.lua;
      }
    ];
  };
  home.sessionPath = [ "${pkgs.nodejs_20}/bin" ];
}
