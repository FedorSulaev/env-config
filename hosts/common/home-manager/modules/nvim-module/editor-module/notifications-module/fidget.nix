{ pkgs, utility, ... }:
{
  imports = [
    ./fidget-dependencies.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = fidget-nvim;
        type = "viml";
        config = utility.toLuaFile ./fidget.lua;
      }
    ];
  };
}
