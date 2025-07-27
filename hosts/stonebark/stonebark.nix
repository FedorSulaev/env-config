{ inputs, lib, config, pkgs, ... }:
{
  imports = [
    # ===== Hardware =====
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
  ];

  boot = {
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];
    kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" "vfio_virqfd" ];
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/nvme0n1" ];
    };
    blacklistedKernelModules = [ "nouveau" "nvidia" ];
    extraModprobeConfig = ''
      options vfio-pci ids=10de:2484,10de:228b
    '';
  };

  services.qemuGuest.enable = true;
  virtualisation.libvirtd.enable = true;
}
