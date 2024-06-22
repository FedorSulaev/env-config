{ pkgs, utility, ... }:
{
  imports = [
    ./settings-module/neovim-settings.nix
    ./navigation-module/neovim-navigation.nix
    ./completion-module/neovim-completion.nix
    ./formatters-module/neovim-formatters.nix
    ./lsp-module/neovim-lsp.nix
    ./debug-module/neovim-debug.nix
    ./testing-module/neovim-testing.nix
    ./editor-module/neovim-editor.nix
    ./search-module/neovim-search.nix
    ./languages-module/neovim-languages.nix
    ./theme-module/neovim-theme.nix
    ./database-module/neovim-database.nix
  ];
  programs.neovim = {
    extraPackages = with pkgs; [
      ripgrep
      fd
      lua54Packages.luarocks
      maven
    ];
    plugins = with pkgs.vimPlugins; [
      # Lint
      {
        plugin = nvim-lint;
        config = utility.toLuaFile ./plugins/lint.lua;
      }
      nvim-treesitter-textobjects
      {
        plugin = (nvim-treesitter.withPlugins (
          # https://github.com/NixOS/nixpkgs/tree/nixos-unstable/pkgs/development/tools/parsing/tree-sitter/grammars
          plugins: with plugins; [
            tree-sitter-lua
            tree-sitter-luadoc
            tree-sitter-vim
            tree-sitter-vimdoc
            tree-sitter-html
            tree-sitter-yaml
            tree-sitter-json
            tree-sitter-comment
            tree-sitter-bash
            tree-sitter-c
            tree-sitter-javascript
            tree-sitter-nix
            tree-sitter-typescript
            tree-sitter-java
            tree-sitter-query # for the tree-sitter itself
            tree-sitter-python
            tree-sitter-go
            tree-sitter-dockerfile
            tree-sitter-diff
            tree-sitter-regex
          ]
        ));
        config = utility.toLuaFile ./plugins/treesitter.lua;
      }
      # Lua
      {
        plugin = neodev-nvim;
        config = utility.toLuaFile ./plugins/neodev.lua;
      }
      # Java
      {
        plugin = nvim-jdtls;
        config = utility.toLuaFile ./plugins/jdtls.lua;
      }
    ];
  };

  # FTplugins
  home.file.".config/nvim/ftplugin/java.lua".source = ./plugins/java.lua;
}
