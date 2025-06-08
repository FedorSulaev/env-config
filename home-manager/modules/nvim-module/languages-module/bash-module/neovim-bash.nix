{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      beautysh
      shellcheck
      nodePackages.bash-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-bash
          ]
        ))
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-bash.lua;
      }
    ];
  };

  home.file.".config/nvim/lsp/bashls.lua".source = ./lspconfig-bash.lua;
}
