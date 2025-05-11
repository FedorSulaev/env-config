{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      python312Packages.pynvim
    ];
  };
}
