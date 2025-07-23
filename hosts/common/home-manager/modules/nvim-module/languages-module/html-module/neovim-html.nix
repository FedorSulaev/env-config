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
        config = utility.toLuaFile ./conform-formatters-html.lua;
      }
      {
        plugin = nvim-ts-autotag;
        config = utility.toLuaFile ./autotag.lua;
      }
    ];
  };
}
