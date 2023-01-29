{
  pkgs ? import <nixpkgs> {},
  backgroundImagePath ? "/home/alissa/.config/background-image.jpg",
  ...
}: let
  pname = "sddm-theme-breeze";
  version = "5.26.90-1";
  arch = "amd64";
  mirror = "https://mirrors.bfsu.edu.cn/debian";
  debName = "${pname}_${version}_${arch}.deb";
  sha256 = "1yxnv2jv7nl3psini69bfnff4457jzw8wildwqgky4j1zbaml2p6";
in
  pkgs.stdenv.mkDerivation {
    dontBuild = true;

    inherit pname version;

    buildInputs = [pkgs.dpkg];
    src = builtins.fetchurl {
      inherit sha256;
      url = "${mirror}/pool/main/p/plasma-workspace/${debName}";
    };

    unpackPhase = ''
      mkdir ${pname}
      dpkg-deb --raw-extract $src ${pname}
    '';
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      sed -i 's|background=.*|background=${backgroundImagePath}|g' ${pname}/usr/share/sddm/themes/breeze/theme.conf
      cp -ar ${pname}/usr/share/sddm/themes/breeze $out/share/sddm/themes
    '';
  }
