{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (python313.withPackages (ps: with ps; [
      ipython
      jupyter
      numpy
      pandas
      matplotlib
      seaborn
      geopandas
      scipy
      sklearn-compat
      imbalanced-learn
      nltk
      shap
      lime
      umap-learn
      torch
      xgboost
      statsmodels
      graphviz
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
