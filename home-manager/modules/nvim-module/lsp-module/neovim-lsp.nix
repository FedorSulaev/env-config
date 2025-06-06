{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
    extraLuaConfig = ''
      ${builtins.readFile ./lspconfig.lua}
    '';
    plugins = with pkgs.vimPlugins; [
      lspkind-nvim
    ];
  };
}
