{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      python313Packages.pynvim
    ];
  };
}
