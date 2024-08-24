{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      mason-lspconfig-nvim
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig.lua;
      }
      lspkind-nvim
    ];
  };
}
