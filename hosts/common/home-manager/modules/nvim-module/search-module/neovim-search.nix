{ pkgs, utility, ... }:
{
  imports = [
    ./telescope-module/telescope.nix
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = trouble-nvim;
        type = "viml";
        config = utility.toLuaFile ./trouble.lua;
      }
      {
        plugin = flash-nvim;
        type = "viml";
        config = utility.toLuaFile ./flash-nvim.lua;
      }
    ];
  };
}
