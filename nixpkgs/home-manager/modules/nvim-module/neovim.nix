{ pkgs, inputs, ... }:
{
  nixpkgs = {
    overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          mason-nvim-dap = prev.vimUtils.buildVimPlugin {
            name = "mason-nvim-dap";
            src = inputs.mason-nvim-dap;
          };
        };
      })
    ];
  };
  programs.neovim =
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in
  {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      ${builtins.readFile ./globals.lua}
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keymaps.lua}
    '';
    plugins = with pkgs.vimPlugins; [
      # File tree
      {
        plugin = neo-tree-nvim;
        config = toLuaFile ./plugins/neo-tree.lua;
      }
      # Completion
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      cmp-path
      {
        plugin = nvim-cmp;
        config = toLuaFile ./plugins/cmp.lua;
      }
      {
        plugin = nvim-autopairs;
        config = toLuaFile ./plugins/autopairs.lua;
      }
      # Formatters
      {
        plugin = conform-nvim;
        config = toLuaFile ./plugins/conform.lua;
      }
      # Debug
      # Creates a beautiful debugger UI
      nvim-dap-ui
      # Installs the debug adapters for you
      mason-nvim
      mason-nvim-dap
      # Add your own debuggers here
      nvim-dap-go
      {
        plugin = nvim-dap;
        config = toLuaFile ./plugins/dap.lua;
      }
      # Theme
      {
        plugin = tokyonight-nvim;
        config = toLuaFile ./plugins/tokyonight.lua;
      }
    ];
  };
}
