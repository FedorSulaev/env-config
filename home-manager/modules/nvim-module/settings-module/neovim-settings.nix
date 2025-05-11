{ ... }:
{
  programs.neovim =
    {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;
      extraLuaConfig = ''
        ${builtins.readFile ./globals.lua}
        ${builtins.readFile ./options.lua}
        ${builtins.readFile ./keymaps.lua}
      '';
    };
}
