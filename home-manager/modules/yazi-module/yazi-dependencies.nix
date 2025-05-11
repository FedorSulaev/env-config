{ pkgs, ... }:
{
  home.packages = with pkgs; [
    file
    unar
    poppler
    ffmpegthumbnailer
  ];

  programs.jq = {
    enable = true;
  };

  programs.fd = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };
}
