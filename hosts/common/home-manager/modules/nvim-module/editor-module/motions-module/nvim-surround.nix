{ pkgs, utility, ... }:
{
  imports = [
    ./nvim-surround-dependencies.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-surround;
        type = "viml";
        config = utility.toLuaFile ./nvim-surround.lua;
      }
    ];
  };
}
