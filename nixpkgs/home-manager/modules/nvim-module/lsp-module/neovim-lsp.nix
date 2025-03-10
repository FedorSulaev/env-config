{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig.lua;
      }
      lspkind-nvim
    ];
  };
}
