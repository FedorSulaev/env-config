{ pkgs, utility, ... }:
{
  imports = [
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = gitsigns-nvim;
        config = utility.toLuaFile ./gitsigns.lua;
      }
      {
        plugin = indent-blankline-nvim;
        config = utility.toLuaFile ./ibl.lua;
      }
      {
        plugin = mini-nvim;
        config = utility.toLuaFile ./mini.lua;
      }
      {
        plugin = todo-comments-nvim;
        config = utility.toLuaFile ./todo-comments.lua;
      }
      {
        plugin = which-key-nvim;
        config = utility.toLuaFile ./which-key.lua;
      }
      vim-tmux-navigator
      vimux
      {
        plugin = lualine-nvim;
        config = utility.toLuaFile ./lualine.lua;
      }
      {
        plugin = nvim-notify;
        config = utility.toLuaFile ./notify.lua;
      }
      {
        plugin = noice-nvim;
        config = utility.toLuaFile ./noice.lua;
      }
      {
        plugin = fidget-nvim;
        config = utility.toLuaFile ./fidget.lua;
      }
    ];
  };
}
