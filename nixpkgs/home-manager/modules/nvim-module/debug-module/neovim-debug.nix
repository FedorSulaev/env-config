{ inputs, pkgs, utility, ... }:
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
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-dap;
        config = utility.toLuaFile ./dap.lua;
      }
      {
        plugin = nvim-dap-ui;
        config = utility.toLuaFile ./dapui.lua;
      }
      {
        plugin = nvim-dap-virtual-text;
        config = utility.toLuaFile ./dap-virtual-text.lua;
      }
      mason-nvim
      {
        plugin = mason-nvim-dap;
        config = utility.toLuaFile ./mason-dap.lua;
      }
      {
        plugin = nvim-dap-go;
        config = utility.toLuaFile ./dap-go.lua;
      }
      cmp-dap
      {
        plugin = nvim-cmp;
        config = utility.toLuaFile ./cmp-dap.lua;
      }
    ];
  };
}
