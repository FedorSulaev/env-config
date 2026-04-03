{ pkgs, ... }:
{
  imports = [
  ];
  programs.neovim = {
    initLua = ''
      ${builtins.readFile ./lspconfig.lua}
    '';
    plugins = with pkgs.vimPlugins; [
      lspkind-nvim
    ];
  };
}
