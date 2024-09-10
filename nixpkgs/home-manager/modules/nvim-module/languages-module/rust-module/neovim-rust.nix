{ pkgs, utility, ... }:
{
  home.packages = with pkgs; [
    cargo
    rustc
    cargo-watch
    rustfilt
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
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-rust.lua;
      }
    ];
  };
}
