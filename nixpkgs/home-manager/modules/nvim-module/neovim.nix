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
      # Editor
      {
        plugin = gitsigns-nvim;
        config = toLuaFile ./plugins/gitsigns.lua;
      }
      {
        plugin = indent-blankline-nvim;
        config = toLuaFile ./plugins/ibl.lua;
      }
      {
        plugin = mini-nvim;
	config = toLuaFile ./plugins/mini.lua;
      }
      plenary-nvim
      {
        plugin = todo-comments-nvim;
	config = toLuaFile ./plugins/todo-comments.lua;
      }
      # Lint
      {
        plugin = nvim-lint;
        config = toLuaFile ./plugins/lint.lua;
      }
      # Search
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      nvim-web-devicons
      {
        plugin = telescope-nvim;
	config = toLuaFile ./plugins/telescope.lua;
      }
      # LSP
      mason-lspconfig-nvim
      mason-tool-installer-nvim
      {
        plugin = fidget-nvim;
        config = toLuaFile ./plugins/fidget.lua;
      }
      {
        plugin = neodev-nvim;
	config = toLuaFile ./plugins/neodev.lua;
      }
      {
        plugin = nvim-lspconfig;
	config = toLuaFile ./plugins/lspconfig.lua;
      }
      # Theme
      {
        plugin = tokyonight-nvim;
        config = toLuaFile ./plugins/tokyonight.lua;
      }
    ];
  };
}
