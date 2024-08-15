{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      lua54Packages.luarocks
      lua-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-lua
            tree-sitter-luadoc
          ]
        )
      )
      {
        plugin = neodev-nvim;
        config = utility.toLuaFile ./neodev.lua;
      }
      {
        plugin = conform-nvim;
        config = utility.toLuaFile ./conform-formatters-lua.lua;
      }
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./lspconfig-lua.lua;
      }
    ];
  };
}
