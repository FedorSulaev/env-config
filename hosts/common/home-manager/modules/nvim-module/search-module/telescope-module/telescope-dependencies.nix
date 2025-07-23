{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      ripgrep
      fd
    ];
    plugins = with pkgs.vimPlugins; [
      telescope-fzf-native-nvim
      plenary-nvim
      nvim-treesitter
      nvim-web-devicons
    ];
  };
}
