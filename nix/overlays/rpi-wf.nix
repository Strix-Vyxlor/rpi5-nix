{ bluez-firmware, firmware-nonfree }:
{ lib, stdenvNoCC, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "raspberrypi-wireless-firmware";
  version = "2024-06-17";

  srcs = [ ]; 

  sourceRoot = ".";

  dontUnpak = true;
  dontBuild = true;
  dontFixum = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/firmware/brcm"
    mkdir -p "$out/lib/firmware/cypress"

    # wifi
    cp -rv "${firmware-nonfree}/debian/config/brcm80211/." "$out/lib/firmware/"
    # ble
    cp -rv "${bluez-firmware}/debian/firmware/broadcom/." "$out/lib/firmware/brcm"

    ln -s "./cyfmac43455-sdio-standard.bin" "$out/lib/firmware/cypress/cyfmac43455-sdio.bin"

    runHook postInstall
  '';

  meta = {
    description = "rpi wwireless firmware";
    homepage = "https://github.com/raspberrypi/firmware";
    license = lib.licenses.unfreeRedistributableFirmware;
    maintainers = with lib.maintainers; [ lopsided98 ];
    platforms = lib.platforms.linux;
  };
}
