{ inputs, ... }:
[
  {
    definition = inputs.NixVirt.lib.domain.writeXML (
      let
        base = inputs.NixVirt.lib.domain.templates.linux {
          name = "riverfall";
          uuid = "185fb457-a102-4a4a-8f4c-f133d1ee962a";
          memory = { count = 2; unit = "GiB"; };
          virtio_video = false;
          storage_vol = {
            pool = "ImagePool";
            volume = "riverfall.qcow2";
          };
          bridge_name = "br0";
          virtio_net = true;
        };
      in
      # extend the base definition with serial + console devices
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
            { vcpu = 0; cpuset = "2"; }
            { vcpu = 1; cpuset = "14"; }
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
