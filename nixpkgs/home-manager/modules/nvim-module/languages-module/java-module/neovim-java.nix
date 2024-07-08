{ pkgs, ... }:
{
  imports = [
    ./jdtls-module/jdtls.nix
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk17_headless;
  };

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
    ];
  };

  home.file.".config/nvim/ftplugin/java.lua".source = ./java.lua;
}
