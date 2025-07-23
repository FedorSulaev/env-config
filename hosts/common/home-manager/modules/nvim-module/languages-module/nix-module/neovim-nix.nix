{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      nixd
      nixpkgs-fmt
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-nix
          ]
        ))
    ];
  };
  home.file.".config/nvim/lsp/nixd.lua".source = ./lspconfig-nix.lua;
  home.file.".config/nvim/after/ftplugin/nix.lua".source = ./nix.lua;
}
