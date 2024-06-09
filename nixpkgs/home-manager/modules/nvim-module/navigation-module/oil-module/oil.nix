{ pkgs, utility, ... }:
{
  imports = [
    ./oil-dependencies.nix
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = oil-nvim;
        config = utility.toLuaFile ./oil.lua;
      }
    ];
  };
}
