{ pkgs, utility, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-nix
          ]
        ))
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-nix.lua;
      }
    ];
  };
}
