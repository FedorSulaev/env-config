{ pkgs, utility, ... }:
{
  imports = [
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lint;
        config = utility.toLuaFile ./lint.lua;
      }
      nvim-treesitter-textobjects
      {
        plugin = (nvim-treesitter.withPlugins (
          # https://github.com/NixOS/nixpkgs/tree/nixos-unstable/pkgs/development/tools/parsing/tree-sitter/grammars
          plugins: with plugins; [
            tree-sitter-comment
            tree-sitter-bash
            tree-sitter-c
            tree-sitter-javascript
            tree-sitter-nix
            tree-sitter-typescript
            tree-sitter-query # for the tree-sitter itself
            tree-sitter-python
            tree-sitter-go
            tree-sitter-dockerfile
            tree-sitter-diff
            tree-sitter-regex
          ]
        ));
        config = utility.toLuaFile ./treesitter.lua;
      }
    ];
  };
}
