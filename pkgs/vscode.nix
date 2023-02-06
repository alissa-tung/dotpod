{pkgs, ...}:
with pkgs;
  (vscode-with-extensions.override {
    vscodeExtensions =
      (with vscode-extensions; [
        ms-vscode-remote.remote-ssh
        llvm-vs-code-extensions.vscode-clangd
        rust-lang.rust-analyzer
        haskell.haskell
        jnoortheen.nix-ide
        tamasfe.even-better-toml
        justusadam.language-haskell
        timonwong.shellcheck
        ms-python.python
        ms-python.vscode-pylance
      ])
      ++ map (extension:
        vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {inherit (extension) name publisher version sha256;};
        })
      (import ../gen/vsc.nix).extensions;
  })
  .overrideAttrs (_: prev: {
    buildInputs = [
      (assert pkgs.lib.lists.length prev.buildInputs == 1; let
        vscode = pkgs.lib.lists.head prev.buildInputs;
      in
        assert vscode.pname == "vscode";
          vscode.overrideAttrs (_: prev: {
            installPhase =
              prev.installPhase
              + "chmod +x $out/lib/vscode/resources/app/node_modules/node-pty/build/Release/spawn-helper";
          }))
    ];
  })
