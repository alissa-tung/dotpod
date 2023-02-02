{pkgs, ...}: let
  pname = "shared-resources";
in
  pkgs.stdenv.mkDerivation {
    inherit pname;
    version = "0.0.0";

    dontBuild = true;
    src = ../cfg;

    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/share/${pname}/
      cp $src/bgi.jpg $out/share/${pname}/
    '';
  }
