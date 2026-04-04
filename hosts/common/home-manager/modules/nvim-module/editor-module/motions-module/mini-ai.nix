{ pkgs, utility, ... }:
{
  imports = [
    ./mini-ai-dependencies.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = mini-nvim;
        type = "viml";
        config = utility.toLuaFile ./mini-ai.lua;
      }
    ];
  };
}
