{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo
    rustc
    cargo-watch
    rustfilt
    lldb
  ];
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
