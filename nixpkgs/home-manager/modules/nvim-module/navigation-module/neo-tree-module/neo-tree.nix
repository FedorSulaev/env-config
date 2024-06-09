{ pkgs, utility, ... }:
{
  imports = [
    ./neo-tree-dependencies.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = neo-tree-nvim;
        config = utility.toLuaFile ./neo-tree.lua;
      }
    ];
  };
}
