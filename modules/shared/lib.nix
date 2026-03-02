{ inputs }:
let
  overlays = [
    (final: prev: {
      # Fixes Darwin build error
      python313 = prev.python313.override {
        packageOverrides = pyFinal: pyPrev: {
          imageio-ffmpeg = pyPrev.imageio-ffmpeg.overridePythonAttrs (_old: {
            doCheck = false;
            doInstallCheck = false;
          });
          imageio = pyPrev.imageio.overridePythonAttrs (_old: {
            doCheck = false;
            doInstallCheck = false;
          });
        };
      };
      python313Packages = final.python313.pkgs;
      ffmpeg = prev.ffmpeg.overrideAttrs (_old: {
        doCheck = false;
        doInstallCheck = false;
      });
    })
  ];

  mkPkgs = system: import inputs.nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };

  pkgs-linux-x86 = mkPkgs "x86_64-linux";
  pkgs-mac-arm = mkPkgs "aarch64-darwin";

  mkNixos = modules: inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    pkgs = pkgs-linux-x86;
    specialArgs = { inherit inputs; };
    inherit modules;
  };
in
{
  inherit overlays mkPkgs pkgs-linux-x86 pkgs-mac-arm mkNixos;
}
