{
  disko.enableConfig = true;
  disko.devices = {
    disk.nvme0n1 = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "table";
        format = "gpt";

        partitions = [
          {
            type = "partition";
            name = "ESP";
            start = "1MiB";
            end = "512MiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              extraArgs = "-n boot";
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }

          {
            type = "partition";
            name = "root";
            start = "512MiB";
            end = "100%";

            content = {
              type = "btrfs";
              extraArgs = "-f -L nixos";
              subvolumes = {
                "@" = { mountpoint = "/"; };

                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress-force=zstd" ];
                };

                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress-force=zstd" "noatime" ];
                };
              };
            };
          }
        ];
      };
    };
  };
}
