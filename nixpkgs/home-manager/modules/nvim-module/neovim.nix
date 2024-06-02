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
      extraPackages = with pkgs; [
        ripgrep
        fd
        lua54Packages.luarocks
        maven
        rust-analyzer
        rustfmt
      ];
      plugins = with pkgs.vimPlugins; [
        # File tree
        {
          plugin = neo-tree-nvim;
          config = toLuaFile ./plugins/neo-tree.lua;
        }
        {
          plugin = oil-nvim;
          config = toLuaFile ./plugins/oil.lua;
        }
        # Completion
        luasnip
        cmp_luasnip
        cmp-nvim-lsp
        cmp-path
        cmp-buffer
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
        {
          plugin = nvim-dap;
          config = toLuaFile ./plugins/dap/dap.lua;
        }
        # Creates a beautiful debugger UI
        {
          plugin = nvim-dap-ui;
          config = toLuaFile ./plugins/dap/dapui.lua;
        }
        {
          plugin = nvim-dap-virtual-text;
          config = toLuaFile ./plugins/dap/dap-virtual-text.lua;
        }
        # Installs the debug adapters for you
        mason-nvim
        {
          plugin = mason-nvim-dap;
          config = toLuaFile ./plugins/dap/mason-dap.lua;
        }
        # Add your own debuggers here
        {
          plugin = nvim-dap-go;
          config = toLuaFile ./plugins/dap/dap-go.lua;
        }
        # Testing
        {
          plugin = vim-test;
          config = toLua "vim.cmd(\"let test#strategy = 'vimux'\")";
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
        {
          plugin = which-key-nvim;
          config = toLuaFile ./plugins/which-key.lua;
        }
        vim-tmux-navigator
        vimux
        # Lint
        {
          plugin = nvim-lint;
          config = toLuaFile ./plugins/lint.lua;
        }
        nvim-treesitter-textobjects
        {
          plugin = (nvim-treesitter.withPlugins (
            # https://github.com/NixOS/nixpkgs/tree/nixos-unstable/pkgs/development/tools/parsing/tree-sitter/grammars
            plugins: with plugins; [
              tree-sitter-lua
              tree-sitter-luadoc
              tree-sitter-vim
              tree-sitter-vimdoc
              tree-sitter-html
              tree-sitter-yaml
              tree-sitter-json
              tree-sitter-markdown
              tree-sitter-comment
              tree-sitter-bash
              tree-sitter-c
              tree-sitter-javascript
              tree-sitter-nix
              tree-sitter-typescript
              tree-sitter-java
              tree-sitter-query # for the tree-sitter itself
              tree-sitter-python
              tree-sitter-go
              tree-sitter-dockerfile
              tree-sitter-diff
              tree-sitter-rust
            ]
          ));
          config = toLuaFile ./plugins/treesitter.lua;
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
        lspkind-nvim
        # Rust
        rustaceanvim
        # Java
        {
          plugin = nvim-jdtls;
          config = toLuaFile ./plugins/jdtls.lua;
        }
        # DB
        vim-dadbod
        vim-dadbod-completion
        vim-dadbod-ui
        # Theme
        {
          plugin = gruvbox-nvim;
          config = toLuaFile ./plugins/theme.lua;
        }
        {
          plugin = lualine-nvim;
          config = toLuaFile ./plugins/lualine.lua;
        }
      ];
    };

  # FTplugins
  home.file.".config/nvim/ftplugin/java.lua".source = ./plugins/java.lua;
}
