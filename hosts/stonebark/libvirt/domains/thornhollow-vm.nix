{ inputs, ... }:
[
  {
    definition = inputs.NixVirt.lib.domain.writeXML (
      let
        base = inputs.NixVirt.lib.domain.templates.linux {
          name = "thornhollow";
          uuid = "37cb5b32-f6d7-433e-bc78-d771b9cd1839";
          vcpu = { count = 2; };
          memory = { count = 2; unit = "GiB"; };
          virtio_video = false;
          storage_vol = {
            pool = "ImagePool";
            volume = "thornhollow.qcow2";
          };
          bridge_name = "br0";
          virtio_net = true;
        };
      in
      base // {
        vcpu = {
          count = 2;
          placement = "static";
        };
        cpu = (base.cpu or { }) // {
          mode = "host-passthrough";
          check = "none";
          topology = {
            sockets = 1;
            cores = 1;
            threads = 2;
          };
        };
        iothreads = { count = 1; };
        cputune = {
          vcpupin = [
            { vcpu = 0; cpuset = "3"; }
            { vcpu = 1; cpuset = "15"; }
          ];
          emulatorpin = {
            cpuset = "1,13";
          };
          iothreadpin = [{ iothread = 1; cpuset = "1,13"; }];
        };
        devices = base.devices or { } // {
          serial = [
            {
              type = "pty";
              target.port = 0;
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
        };
      }
    );
    active = true;
  }
]
