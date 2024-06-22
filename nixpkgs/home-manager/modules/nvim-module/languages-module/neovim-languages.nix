{ ... }:
{
  imports = [
    ./lua-module/neovim-lua.nix
    ./java-module/neovim-java.nix
    ./rust-module/neovim-rust.nix
    ./markdown-module/neovim-markdown.nix
  ];
}
