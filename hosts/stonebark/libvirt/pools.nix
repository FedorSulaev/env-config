{ inputs, ... }:
{
  virtualisation.libvirt.connections."qemu:///system".pools = [
    {
      definition = inputs.NixVirt.lib.pool.writeXML {
        name = "ImagePool";
        uuid = "c0fbd6d8-0e05-4287-8e37-5f8699ea7d3b";
        type = "dir";
        target.path = "/var/lib/libvirt/images";
      };
      active = true;
      volumes =
        let
          volumeSpecs = [
            { name = "riverfall.qcow2"; sizeGiB = 40; }
            { name = "sunpeak.qcow2"; sizeGiB = 512; }
            { name = "thornhollow.qcow2"; sizeGiB = 40; }
          ];
        in
        map
          (volume: {
            definition = inputs.NixVirt.lib.volume.writeXML {
              name = volume.name;
              capacity = {
                count = volume.sizeGiB;
                unit = "GiB";
              };
            };
          })
          volumeSpecs;
    }
  ];
}
