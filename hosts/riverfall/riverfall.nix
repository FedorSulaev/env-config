{ pkgs, ... }:
{
  imports = [
    "${pkgs.path}/nixos/modules/virtualisation/qemu-vm.nix"
  ];

  virtualisation.qemu.diskInterface = "virtio";
  virtualisation.qemu.memorySize = 2048;
  virtualisation.qemu.networkingOptions = [ "bridge=br0" ];
}
