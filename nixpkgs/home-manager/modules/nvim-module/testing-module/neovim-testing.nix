{ pkgs, utility, ... }:
{
  imports = [
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = vim-test;
        config = utility.toLua "vim.cmd(\"let test#strategy = 'vimux'\")";
      }
    ];
  };
}

