{ pkgs, ... }:
{
    programs.gh = {
        enable = true;
        settings = {
            git_protocol = "https";
            editor = "nvim";
            prompt = "enabled";
        };
    };
}
