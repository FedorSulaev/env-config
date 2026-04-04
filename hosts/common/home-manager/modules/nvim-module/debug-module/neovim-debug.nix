{ pkgs, utility, ... }:
{
  imports = [
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-dap;
        type = "viml";
        config = utility.toLuaFile ./dap.lua;
      }
      {
        plugin = nvim-dap-ui;
        type = "viml";
        config = utility.toLuaFile ./dapui.lua;
      }
      {
        plugin = nvim-dap-virtual-text;
        type = "viml";
        config = utility.toLuaFile ./dap-virtual-text.lua;
      }
      {
        plugin = nvim-dap-go;
        type = "viml";
        config = utility.toLuaFile ./dap-go.lua;
      }
      # rest-nvim
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-http
          ]
        ))
      {
        plugin = rest-nvim;
        type = "viml";
        config = utility.toLuaFile ./rest-nvim.lua;
      }
    ];
  };
}
