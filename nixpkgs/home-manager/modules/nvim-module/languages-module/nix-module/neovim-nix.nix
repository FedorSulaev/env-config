{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      nil
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-nix
          ]
        ))
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-nix.lua;
      }
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig-nix.lua;
      }
    ];
  };
}
