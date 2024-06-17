{
  description = "raspberry-pi-nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url =  "path:./nix";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      rpi-config = { pkgs, lib, ... }: {
        time.timeZone = "Europe/Brussels";
        users.users.root.initialPassword = "root";
        networking = {
          hostName = "rpi-nix";
          useDHCP = false;
          interfaces = { wlan0.useDHCP = true; };
        };
        environment.systemPackages = with pkgs; [ bluez bluez-tools ];
        hardware = {
          bluetooth.enable = true;
          raspberry-pi = {
            config = {
              all = {
                base-dt-params = {
                  # enable autoprobing of bluetooth driver
                  # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                  krnbt = {
                    enable = true;
                    value = "on";
                  };
                };
                dt-overlays = {
                  vc4-kms-v3d = {
                    enable = true;
                    params = { };
                  };
                };
              };
            };
          };
        };
      };

    in {
      nixosConfigurations = {
        rpi-nixos = nixosSystem {
          system = "aarch64-linux";
          modules = [ raspberry-pi-nix.nixosModules.raspberry-pi rpi-config ];
        };
      };
    };
}
