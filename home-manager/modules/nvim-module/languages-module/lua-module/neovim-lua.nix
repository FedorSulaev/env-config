{ pkgs, utility, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      lua54Packages.luarocks
      lua54Packages.luacheck
      lua-language-server
      stylua
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
      nvim-cmp
    ];
  };

  home.file.".config/nvim/lsp/lua_ls.lua".source = ./lspconfig-lua.lua;
}
