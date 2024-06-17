{
  description = "raspberry-pi nixos configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
    u-boot-src = {
      flake = false;
      url = "https://github.com/u-boot/u-boot/archive/refs/tags/v2024.07-rc4.tar.gz";
    };
    rpi-linux-6_6-src = {
      flake = false;
      url = "github:raspberrypi/linux/stable_20240529";
    };
    rpi-firmware-src = {
      flake = false;
      url = "github:raspberrypi/firmware/1.20240529";
    };
    rpi-firmware-nonfree-src = {
      flake = false;
      url = "github:RPi-Distro/firmware-nonfree/88aa085bfa1a4650e1ccd88896f8343c22a24055";
    };
    rpi-bluez-firmware-src = {
      flake = false;
      url = "github:RPi-Distro/bluez-firmware/d9d4741caba7314d6500f588b1eaa5ab387a4ff5";
    };
  };

  outputs = srcs@{ self, ... }:
    let
      pinned = import srcs.nixpkgs {
        system = "aarch64-linux";
        overlays = with self.overlays; [ core ];
      };
    in
    {
      overlays = {
        core = import ./overlays (builtins.removeAttrs srcs [ "self" ]);
      };
      nixosModules.raspberry-pi = import ./rpi {
        inherit pinned;
        core-overlay = self.overlays.core;
      };
      packages.aarch64-linux = {
        linux = pinned.rpi-kernels.latest.kernel;
      };
    };
}
