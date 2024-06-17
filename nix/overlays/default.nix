{ u-boot-src, rpi-linux-6_6-src, rpi-firmware-src, rpi-firmware-nonfree-src, rpi-bluez-firmware-src, ... }:

final: prev:
let

  latest = "v6_6_33";

  rpi-kernel = { kernel, version, fw, wireles-fw, argsOverride ? null }:
    let
      new-kernel = prev.linux_rpi4.override {
        argsOverride = {
          src = kernel;
          inherit version;
          modDirVersion = version;
        } // (if builtins.isNull argsOverride then { } else argsOverride );
      };

      new-fw = prev.raspberrypifw.overrideAttrs (oldfs: { src = fw; });
      new-wireless-fw = final.callPage wireles-fw { };
      version-slug = builtins.replaceStrings [ "." ] [ "_" ] version;
    in 
    {
      "v${version-slug}" = {
        kernel = new-kernel;
        firmware = new-fw;
        wireless-firmware = new-wireless-fw;
      };
    };
    
    rpi-kernels = builtins.foldl' (b: a: b // rpi-kernels a) { };
in 
{
  compressFirmwareXz = x: x;
  compressFirmwareZstd = x: x;

  uboot_rpi_arm64 = prev.buildUboot rec {
    defconfig = "rpi_arm64_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot.bin" ];
    version = "2024.07-rc4";
    src = u-boot-src;
  };

  raspberrypiWirelessFirmware = final.rpi-kernels.latest.wireless-firmware;
  raspberrypifw = final.rpi-kernels.latest.firmware;
} // {
  rpi-kernels = rpi-kernels [{
    version = "6.6.33";
    fw = rpi-firmware-src;
    wireless-fw = import ./rpi-wf.nix {
      bluez-firmware = rpi-bluez-firmware-src;
      firmware-nonfree = rpi-firmware-nonfree-src;
    };

  }] // {
    latest = final.rpi-kernels."${latest}";
  };
}
