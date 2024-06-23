{ pkgs, utility, ... }:
{
  imports = [
    ./telescope-dependencies.nix
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      {
        plugin = telescope-nvim;
        config = utility.toLuaFile ./telescope.lua;
      }
    ];
  };
}
