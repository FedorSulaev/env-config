{ ... }:
{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              type = "EF00"; # EFI System Partition
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              name = "swap";
              type = "8200"; # Linux swap
              size = "8G";
              content = { type = "swap"; };
            };
            root = {
              name = "root";
              type = "8300"; # Linux filesystem
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/";
              };
            };
          };
        };
      };

      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              name = "storage";
              type = "8300";
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/srv/storage"; # passive storage
              };
            };
          };
        };
      };
    };
  };
}


