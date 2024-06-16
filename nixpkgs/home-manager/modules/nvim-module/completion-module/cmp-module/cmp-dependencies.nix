{ pkgs, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      luasnip
    ];
    extraLuaPackages = ps: [ ps.jsregexp ];
  };
}
