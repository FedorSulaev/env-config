{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      ${builtins.readFile ./globals.lua}
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keymaps.lua}
    '';
    plugins = with pkgs.vimPlugins; [

    ];
  };
}
