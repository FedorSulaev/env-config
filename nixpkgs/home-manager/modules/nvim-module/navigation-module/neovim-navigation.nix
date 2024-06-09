{ pkgs, utility, ... }:
{
  programs.neovim =
    {
      plugins = with pkgs.vimPlugins; [
        # File tree
        {
          plugin = neo-tree-nvim;
          config = utility.toLuaFile ./neo-tree.lua;
        }
        {
          plugin = oil-nvim;
          config = utility.toLuaFile ./oil.lua;
        }
      ];
    };
}
