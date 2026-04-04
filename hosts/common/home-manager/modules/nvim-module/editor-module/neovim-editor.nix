{ pkgs, utility, ... }:
{
  imports = [
    ./motions-module/nvim-surround.nix
    ./motions-module/mini-ai.nix
    ./notifications-module/fidget.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = gitsigns-nvim;
        type = "viml";
        config = utility.toLuaFile ./gitsigns.lua;
      }
      {
        plugin = indent-blankline-nvim;
        type = "viml";
        config = utility.toLuaFile ./ibl.lua;
      }
      {
        plugin = todo-comments-nvim;
        type = "viml";
        config = utility.toLuaFile ./todo-comments.lua;
      }
      {
        plugin = which-key-nvim;
        type = "viml";
        config = utility.toLuaFile ./which-key.lua;
      }
      vim-tmux-navigator
      vimux
      {
        plugin = lualine-nvim;
        type = "viml";
        config = utility.toLuaFile ./lualine.lua;
      }
      {
        plugin = nvim-notify;
        type = "viml";
        config = utility.toLuaFile ./notify.lua;
      }
      {
        plugin = noice-nvim;
        type = "viml";
        config = utility.toLuaFile ./noice.lua;
      }
    ];
  };
}
