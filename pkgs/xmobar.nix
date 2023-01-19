{ pkgs, ... }:

pkgs.writers.writeHaskellBin "xmobar"
{
  libraries = [ pkgs.haskellPackages.xmobar ];
}
  (builtins.readFile ../cfg/xmobar.hs)
