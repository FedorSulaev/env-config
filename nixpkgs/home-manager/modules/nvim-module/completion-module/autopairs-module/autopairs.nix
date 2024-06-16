{ pkgs, utility, ... }:
{
  imports = [
    ./autopairs-dependencies.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-autopairs;
        config = utility.toLuaFile ./autopairs.lua;
      }
    ];
  };
}
