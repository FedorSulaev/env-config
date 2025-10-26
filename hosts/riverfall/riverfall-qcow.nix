{ ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input serial
      terminal_output serial
    '';
  };

  boot.kernelParams = [ "console=ttyS0,115200n8" ];

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
