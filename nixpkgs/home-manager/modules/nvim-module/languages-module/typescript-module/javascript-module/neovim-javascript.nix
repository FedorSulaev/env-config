{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      nodejs_20
    ];
  };
  home.sessionPath = [ "${pkgs.nodejs_20}/bin" ];
}
