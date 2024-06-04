{ ... }:
{
  imports = [
    ./yazi-dependencies.nix
  ];

  programs.yazi = {
    enable = true;
  };
}

