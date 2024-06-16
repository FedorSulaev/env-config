{ pkgs, utility, ... }:
{
  imports = [
    ./cmp-dependencies.nix
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      cmp_luasnip
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      {
        plugin = nvim-cmp;
        config = utility.toLuaFile ./cmp.lua;
      }
    ];
  };
}
