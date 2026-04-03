{ pkgs, ... }:

let
  python = pkgs.python313;

  pythonPackages = python.pkgs;

  aif360 = pythonPackages.buildPythonPackage rec {
    pname = "aif360";
    version = "0.6.1";
    pyproject = true;
    src = pythonPackages.fetchPypi {
      inherit pname version;
      hash = "sha256-Y1r8C754Xgj6JC7uXlCAI4GT0Fg7wPUAahMgUNT7d/I=";
    };
    build-system = with pythonPackages; [
      setuptools
      wheel
    ];
    dependencies = with pythonPackages; [
      numpy
      scipy
      pandas
      scikit-learn
      matplotlib
    ];
    doCheck = false;
  };
in
{
  home.packages = with pkgs; [
    (python.withPackages (ps: with ps; [
      ipython
      jupyter
      ipykernel

      numpy
      pandas
      matplotlib
      seaborn
      geopandas
      scipy
      scikit-learn
      imbalanced-learn
      nltk
      shap
      lime
      umap-learn
      torch
      xgboost
      statsmodels
      graphviz
      flask

      aif360
    ]))
  ];

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (plugins: with plugins; [
        tree-sitter-python
      ]))
    ];
  };
}
