{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
    extraPackages = with pkgs; [
      maven
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-java
          ]
        )
      )
      {
        plugin = nvim-jdtls;
        config = utility.toLuaFile ./jdtls.lua;
      }
    ];
  };

  home.file.".config/nvim/ftplugin/java.lua".source = ./java.lua;
}
