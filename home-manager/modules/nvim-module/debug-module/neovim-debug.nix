{ pkgs, utility, ... }:
{
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
      {
        plugin = nvim-dap-go;
        config = utility.toLuaFile ./dap-go.lua;
      }
    ];
  };
}
