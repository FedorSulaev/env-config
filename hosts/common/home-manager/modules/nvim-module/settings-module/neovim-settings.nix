{ ... }:
{
  programs.neovim =
    {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;
      initLua = ''
        ${builtins.readFile ./globals.lua}
        ${builtins.readFile ./options.lua}
        ${builtins.readFile ./keymaps.lua}
      '';
    };
}
