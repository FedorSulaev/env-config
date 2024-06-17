{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      {
        plugin = telescope-nvim;
        config = utility.toLuaFile ./telescope.lua;
      }
      {
        plugin = trouble-nvim;
        config = utility.toLuaFile ./trouble.lua;
      }
    ];
  };
}
