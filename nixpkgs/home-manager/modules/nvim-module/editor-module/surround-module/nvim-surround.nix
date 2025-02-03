{ pkgs, utility, ... }:
{
  imports = [
    ./nvim-surround-dependencies.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-surround;
        config = utility.toLuaFile ./nvim-surround.lua;
      }
    ];
  };
}
