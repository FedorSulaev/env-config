{ pkgs, ... }:
{
  virtualisation.qemu.options = [
    "-m"
    "2048"
    "-device"
    "virtio-net-pci,netdev=net0"
    "-netdev"
    "bridge,id=net0,br=br0"
  ];
}
