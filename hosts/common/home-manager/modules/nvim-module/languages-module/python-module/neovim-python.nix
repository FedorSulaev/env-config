{ pkgs, ... }:
let
  buildPythonPackage = pkgs.python313Packages.buildPythonPackage;
  fetchPypi = pkgs.python313Packages.fetchPypi;
  contextily = buildPythonPackage
    rec {
      pname = "contextily";
      version = "1.7.0";

      doCheck = false;
      dontUseCmakeConfigure = true;
      format = "pyproject";

      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256:6534faa5702b89b46d0d81b4c538754f2d8b3dd8cc298454b11ccedfa67e73ac";
      };

      propagatedBuildInputs = with pkgs.python313Packages; [
        setuptools-scm
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
    (python313.withPackages (ps: with ps; [
      ipython
      jupyter
      numpy
      pandas
      matplotlib
      seaborn
      contextily
      geopandas
      scipy
      sklearn-compat
      imbalanced-learn
      nltk
      optuna
      shap
      lime
      umap-learn
      torch
      xgboost
      statsmodels
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
