{ pkgs, utility, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-html
          ]
        ))
      {
        plugin = conform-nvim;
        type = "viml";
        config = utility.toLuaFile ./conform-formatters-html.lua;
      }
      {
        plugin = nvim-ts-autotag;
        type = "viml";
        config = utility.toLuaFile ./autotag.lua;
      }
    ];
  };
}
