{ pkgs, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      nvim-web-devicons
      nui-nvim
    ];
  };
}
