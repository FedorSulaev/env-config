{ pkgs, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-dadbod-completion
      luasnip
    ];
    extraLuaPackages = ps: [ ps.jsregexp ];
  };
}
