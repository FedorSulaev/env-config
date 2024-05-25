{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;
    initExtra = "[[ ! $(command -v nix) && -e ' /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ' ]] && source ' /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh '";
  };
  programs.starship = {
    enable = true;
    settings = { };
  };
}
