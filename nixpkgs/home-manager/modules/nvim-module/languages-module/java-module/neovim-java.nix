{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
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
