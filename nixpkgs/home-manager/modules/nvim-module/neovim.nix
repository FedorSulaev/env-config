{ pkgs, inputs, utility, ... }:
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
  imports = [
    ./settings-module/neovim-settings.nix
    ./navigation-module/neovim-navigation.nix
    ./completion-module/neovim-completion.nix
    ./formatters-module/neovim-formatters.nix
  ];
  programs.neovim = {
    extraPackages = with pkgs; [
      ripgrep
      fd
      lua54Packages.luarocks
      maven
      rust-analyzer
      rustfmt
    ];
    plugins = with pkgs.vimPlugins; [
      # Debug
      {
        plugin = nvim-dap;
        config = utility.toLuaFile ./plugins/dap/dap.lua;
      }
      # Creates a beautiful debugger UI
      {
        plugin = nvim-dap-ui;
        config = utility.toLuaFile ./plugins/dap/dapui.lua;
      }
      {
        plugin = nvim-dap-virtual-text;
        config = utility.toLuaFile ./plugins/dap/dap-virtual-text.lua;
      }
      # Installs the debug adapters for you
      mason-nvim
      {
        plugin = mason-nvim-dap;
        config = utility.toLuaFile ./plugins/dap/mason-dap.lua;
      }
      # Add your own debuggers here
      {
        plugin = nvim-dap-go;
        config = utility.toLuaFile ./plugins/dap/dap-go.lua;
      }
      # Testing
      {
        plugin = vim-test;
        config = utility.toLua "vim.cmd(\"let test#strategy = 'vimux'\")";
      }
      # Editor
      {
        plugin = gitsigns-nvim;
        config = utility.toLuaFile ./plugins/gitsigns.lua;
      }
      {
        plugin = indent-blankline-nvim;
        config = utility.toLuaFile ./plugins/ibl.lua;
      }
      {
        plugin = mini-nvim;
        config = utility.toLuaFile ./plugins/mini.lua;
      }
      {
        plugin = todo-comments-nvim;
        config = utility.toLuaFile ./plugins/todo-comments.lua;
      }
      {
        plugin = which-key-nvim;
        config = utility.toLuaFile ./plugins/which-key.lua;
      }
      vim-tmux-navigator
      vimux
      {
        plugin = lualine-nvim;
        config = utility.toLuaFile ./plugins/lualine.lua;
      }
      {
        plugin = nvim-notify;
        config = utility.toLuaFile ./plugins/notify.lua;
      }
      {
        plugin = noice-nvim;
        config = utility.toLuaFile ./plugins/noice.lua;
      }
      # Lint
      {
        plugin = nvim-lint;
        config = utility.toLuaFile ./plugins/lint.lua;
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
            tree-sitter-markdown-inline
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
            tree-sitter-regex
          ]
        ));
        config = utility.toLuaFile ./plugins/treesitter.lua;
      }
      # Search
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      {
        plugin = telescope-nvim;
        config = utility.toLuaFile ./plugins/telescope.lua;
      }
      {
        plugin = trouble-nvim;
        config = utility.toLuaFile ./plugins/trouble.lua;
      }
      # LSP
      mason-lspconfig-nvim
      mason-tool-installer-nvim
      {
        plugin = fidget-nvim;
        config = utility.toLuaFile ./plugins/fidget.lua;
      }
      {
        plugin = neodev-nvim;
        config = utility.toLuaFile ./plugins/neodev.lua;
      }
      {
        plugin = nvim-lspconfig;
        config = utility.toLuaFile ./plugins/lspconfig.lua;
      }
      lspkind-nvim
      # Rust
      rustaceanvim
      # Java
      {
        plugin = nvim-jdtls;
        config = utility.toLuaFile ./plugins/jdtls.lua;
      }
      # DB
      vim-dadbod
      vim-dadbod-completion
      vim-dadbod-ui
      # Theme
      {
        plugin = gruvbox-nvim;
        config = utility.toLuaFile ./plugins/theme.lua;
      }
    ];
  };

  # FTplugins
  home.file.".config/nvim/ftplugin/java.lua".source = ./plugins/java.lua;
}
