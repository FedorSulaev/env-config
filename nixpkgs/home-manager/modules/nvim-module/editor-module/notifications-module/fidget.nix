{ pkgs, utility, ... }:
{
  imports = [
    ./fidget-dependencies.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = fidget-nvim;
        config = utility.toLuaFile ./fidget.lua;
      }
    ];
  };
}
