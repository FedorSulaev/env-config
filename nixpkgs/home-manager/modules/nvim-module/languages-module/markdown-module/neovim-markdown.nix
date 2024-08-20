{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      markdownlint-cli
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-markdown
            tree-sitter-markdown-inline
          ]
        ))
    ];
  };
}
