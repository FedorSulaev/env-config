{ pkgs, ... }:
{
  imports = [
    ./settings-module/neovim-settings.nix
    ./navigation-module/neovim-navigation.nix
    ./completion-module/neovim-completion.nix
    ./formatters-module/neovim-formatters.nix
    ./lint-module/neovim-lint.nix
    ./lsp-module/neovim-lsp.nix
    ./debug-module/neovim-debug.nix
    ./testing-module/neovim-testing.nix
    ./editor-module/neovim-editor.nix
    ./search-module/neovim-search.nix
    ./languages-module/neovim-languages.nix
    ./theme-module/neovim-theme.nix
    ./database-module/neovim-database.nix
  ];
  # TODO: Move to modules
  programs.neovim = {
    extraPackages = with pkgs; [
      ripgrep
      fd
      lua54Packages.luarocks
      maven
    ];
  };
}
