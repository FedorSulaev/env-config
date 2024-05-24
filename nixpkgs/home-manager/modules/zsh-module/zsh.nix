{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;
    initExtra = "[[ ! $(command -v nix) && -e ' /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ' ]] && source ' /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh '";
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    plugins = with pkgs; [
      {
        file = "powerlevel10k.zsh-theme";
        name = "powerlevel10k";
        src = "${zsh-powerlevel10k}/share/zsh-powerlevel10k";
      }
      {
        name = "powerlevel10k-config";
        src = ./.;
        file = "p10k.zsh";
      }
    ];
  };
}
