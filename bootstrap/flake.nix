{
  description = "Minimal NixOS configuration for bootstrapping systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;

      minimalSpecialArgs = {
        inherit inputs outputs;
      };
      newConfig =
        name: disk: swapSize: useLuks: useImpermanence:
        (
          let
            diskSpecPath =
              if useLuks && useImpermanence then
                ../hosts/common/disks/luks-impermanence-disk.nix
              else if !useLuks && useImpermanence then
                ../hosts/common/disks/impermanence-disk.nix
              else
                ../hosts/common/disks/host-disk.nix;
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = minimalSpecialArgs;
            modules = [
              inputs.disko.nixosModules.disko
              diskSpecPath
              {
                _module.args = {
                  inherit disk;
                  withSwap = swapSize > 0;
                  swapSize = builtins.toString swapSize;
                };
              }
              ./minimal-configuration.nix
              #../hosts/nixos/${name}/hardware-configuration.nix
              { networking.hostName = name; }
            ];
          }
        );
    in
    {
      nixosConfigurations = {
        # host = newConfig "name" disk" "swapSize" "useLuks" "useImpermanence"
        # Swap size is in GiB
        personalapps = newConfig "personalapps" "/dev/vda" 0 false false;
        testlab = newConfig "testlab" "/dev/vda" 0 false false;
        test = newConfig "test" "/dev/vda" 0 false false;
        stonebark = newConfig "stonebark" "/dev/vda" 0 false false;
      };
    };
}
