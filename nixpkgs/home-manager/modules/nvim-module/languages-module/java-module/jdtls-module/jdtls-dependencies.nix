{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      python311Packages.pynvim
    ];
  };
}
