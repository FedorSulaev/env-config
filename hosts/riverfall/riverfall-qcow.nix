{ ... }:
{
  # ensure kernel modules for virtio disks are included early
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "9p"
    "9pnet_virtio"
  ];

  # Enable a simple boot loader for disk images
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda"; # virtual disk device in qcow2 image
  };
  fileSystems."/" = {
    device = "/dev/vda";
    fsType = "ext4";
  };

  boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];

  # Enable getty on serial console
  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };

  services = {
    qemuGuest.enable = true;
  };

}
