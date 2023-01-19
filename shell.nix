{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [ ] ++ [
    (haskellPackages.ghcWithPackages (ghcPkg:
      with ghcPkg; [
        haskell-language-server

        xmonad
        xmonad-contrib
        xmobar
      ]))
  ];
}
