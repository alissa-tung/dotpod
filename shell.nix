{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [ ] ++ [
    (haskellPackages.ghcWithPackages (ghcPkgs:
      with ghcPkgs; [
        haskell-language-server

        xmonad
        xmonad-contrib
        xmobar
      ]))
  ];
}
