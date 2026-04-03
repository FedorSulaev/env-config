{ ... }:
{
  programs.neovim =
    {
      initLua = ''
        ${builtins.readFile ./terminal.lua}
      '';
    };
}
