{ pkgs, ... }:
{
  virtualisation.qemu = {
    diskInterface = "virtio";
    memorySize = 2048;
    networkingOptions = [ "bridge=br0" ];
  };
}
