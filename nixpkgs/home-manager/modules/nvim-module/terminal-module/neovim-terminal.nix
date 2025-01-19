{ ... }:
{
  programs.neovim =
    {
      extraLuaConfig = ''
        ${builtins.readFile ./terminal.lua}
      '';
    };
}
