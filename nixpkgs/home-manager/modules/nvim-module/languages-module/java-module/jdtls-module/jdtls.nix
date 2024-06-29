{ pkgs, utility, ... }:
{
  imports = [
    ./jdtls-dependencies.nix
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-jdtls;
        config = utility.toLuaFile ./jdtls.lua;
      }
    ];
  };
}
