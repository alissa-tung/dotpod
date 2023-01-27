{
  lib,
  pkgs,
  modulesPath,
  ...
} @ inputs: let
  installerPath = "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix";
  baseMod = (import "${modulesPath}/profiles/base.nix") inputs;

  defaultSystemPackages = baseMod.environment.systemPackages;
  defaultSupportedFilesystems = baseMod.boot.supportedFilesystems;
in {
  imports = [installerPath];

  environment.systemPackages =
    defaultSystemPackages
    ++ (with pkgs; [git fd gnumake]);
  boot.supportedFilesystems =
    lib.mkForce (lib.lists.filter (x: x != "zfs") defaultSupportedFilesystems);

  boot.kernelPackages = pkgs.linuxPackages_latest;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  networking.wireless.iwd.enable = true;
  networking.wireless.enable = lib.mkForce false;
}
