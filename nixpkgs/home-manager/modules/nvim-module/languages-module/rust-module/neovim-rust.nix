{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      rust-analyzer
      rustfmt
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-rust
          ]
        ))
      rustaceanvim
    ];
  };
}
