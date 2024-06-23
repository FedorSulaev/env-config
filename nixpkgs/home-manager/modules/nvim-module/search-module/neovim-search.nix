{ pkgs, utility, ... }:
{
  imports = [
    ./telescope-module/telescope.nix
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = trouble-nvim;
        config = utility.toLuaFile ./trouble.lua;
      }
    ];
  };
}
