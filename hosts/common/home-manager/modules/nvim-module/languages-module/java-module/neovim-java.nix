{ pkgs, utility, ... }:
{
  imports = [
    ./jdtls-module/jdtls.nix
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk21_headless;
  };

  programs.neovim = {
    extraPackages = with pkgs; [
      maven
      jdt-language-server
      lombok
      vscode-extensions.vscjava.vscode-java-debug
      vscode-extensions.vscjava.vscode-java-test
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
        plugin = nvim-dap;
        config = utility.toLuaFile ./dap-java.lua;
      }
    ];
  };

  home.file.".config/nvim/after/ftplugin/java.lua".source = ./java.lua;
  home.file.".config/nvim/after/ftplugin/eclipse-java-google-style.xml".source = ./eclipse-java-google-style.xml;
  home.file.".lombok/lombok.jar".source = "${pkgs.lombok}/share/java/lombok.jar";
  home.file.".java-debug/java-debug.jar".source = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-0.50.0.jar";
  home.file.".java-test/java-test.jar".source = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/com.microsoft.java.test.plugin-0.40.1.jar";
}
