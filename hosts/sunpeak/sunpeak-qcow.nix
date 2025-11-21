{ ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
  ];

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  services.qemuGuest.enable = true;

  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Restart = "always";
  };
}
