{ pkgs, ... }:
let
  buildPythonPackage = pkgs.python3Packages.buildPythonPackage;
  fetchPypi = pkgs.python3Packages.fetchPypi;
  contextily = buildPythonPackage
    rec {
      pname = "contextily";
      version = "1.6.2";

      doCheck = false;
      dontUseCmakeConfigure = true;
      format = "pyproject";

      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-PHR5JSab4kipsadhhZ4F0WgShuBNXQeWva8d40CUdLs=";
      };

      propagatedBuildInputs = with pkgs.python3Packages; [
        setuptools_scm
        geopy
        matplotlib
        mercantile
        pillow
        rasterio
        requests
        joblib
        xyzservices
      ];
    };
in
{

  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [
      ipython
      jupyter
      numpy
      pandas
      matplotlib
      seaborn
      contextily
    ]))
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins
        (
          plugins: with plugins; [
            tree-sitter-python
          ]
        ))
    ];
  };
}
