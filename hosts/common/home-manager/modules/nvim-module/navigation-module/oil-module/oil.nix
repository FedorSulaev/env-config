{ pkgs, utility, ... }:
{
  imports = [
    ./oil-dependencies.nix
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = oil-nvim;
        type = "viml";
        config = utility.toLuaFile ./oil.lua;
      }
    ];
  };
}
