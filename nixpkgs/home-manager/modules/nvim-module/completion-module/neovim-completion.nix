{ pkgs, utility, ... }:
{
  imports = [
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      {
        plugin = nvim-cmp;
        config = utility.toLuaFile ./cmp.lua;
      }
      {
        plugin = nvim-autopairs;
        config = utility.toLuaFile ./autopairs.lua;
      }
    ];
  };
}
