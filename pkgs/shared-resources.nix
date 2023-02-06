{pkgs, ...}: let
  pname = "shared-resources";
in
  pkgs.stdenv.mkDerivation {
    inherit pname;
    version = "0.0.0";

    dontBuild = true;
    src = ./shared-resources;

    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/
      cp -r $src/* $out/
    '';
  }
