{ inputs, ... }:
[
  {
    definition = inputs.NixVirt.lib.domain.writeXML (
      let
        base = inputs.NixVirt.lib.domain.templates.q35 {
          name = "sunpeak";
          uuid = "f33b7e4a-15c3-4c67-a913-3a6c8c1caa4d";

          memory = {
            count = 24;
            unit = "GiB";
          };

          storage_vol = {
            pool = "ImagePool";
            volume = "sunpeak.qcow2";
          };

          bridge_name = "br0";
          virtio_net = true;

          virtio_video = false;
        };
      in
      base // {

        vcpu = {
          count = 12;
          placement = "static";
        };

        cpu = (base.cpu or { }) // {
          mode = "host-passthrough";
          check = "none";
          topology = {
            sockets = 1;
            cores = 6;
            threads = 2;
          };
        };

        iothreads = { count = 1; };

        # CPU pinning
        cputune = {
          vcpupin = [
            # physical cores 6–11 (thread 0)
            { vcpu = 0; cpuset = "6"; }
            { vcpu = 1; cpuset = "7"; }
            { vcpu = 2; cpuset = "8"; }
            { vcpu = 3; cpuset = "9"; }
            { vcpu = 4; cpuset = "10"; }
            { vcpu = 5; cpuset = "11"; }

            # physical cores 6–11 (thread 1 / SMT)
            { vcpu = 6; cpuset = "18"; }
            { vcpu = 7; cpuset = "19"; }
            { vcpu = 8; cpuset = "20"; }
            { vcpu = 9; cpuset = "21"; }
            { vcpu = 10; cpuset = "22"; }
            { vcpu = 11; cpuset = "23"; }
          ];

          emulatorpin = {
            cpuset = "1,13";
          };

          iothreadpin = [{ iothread = 1; cpuset = "1,13"; }];
        };

        devices = (base.devices or { }) // {
          #video = [ ];
          #graphics = [ ];
          #channel = [ ];
          #input = [ ];
          #redirdev = [ ];
          #hub = [ ];
          #audio = [ ];
          #sound = [ ];

          serial = [
            {
              type = "pty";
              target = {
                port = 0;
              };
            }
          ];

          console = [
            {
              type = "pty";
              target = {
                type = "serial";
                port = 0;
              };
            }
          ];

          hostdev = [
            {
              type = "pci";
              managed = true;
              source = {
                address = {
                  domain = 0;
                  bus = 9;
                  slot = 0;
                  function = 0;
                };
              };
            }
            {
              type = "pci";
              managed = true;
              source = {
                address = {
                  domain = 0;
                  bus = 9;
                  slot = 0;
                  function = 1;
                };
              };
            }
            {
              type = "pci";
              managed = true;
              driver = { name = "vfio"; };
              source.address = {
                domain = 0;
                bus = 13; # 0x0d == 13
                slot = 0;
                function = 3;
              };
            }
            {
              mode = "subsystem";
              type = "usb";
              managed = true;
              source.vendor.id = 32903; # 0x8087
              source.product.id = 50; # 0x0032
            }
          ];
        };
      }
    );
    active = true;
  }
]
