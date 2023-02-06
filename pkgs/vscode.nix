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
    buildInputs = lib.lists.map (x:
      if x.pname == "vscode"
      then
        x.overrideAttrs (_: prev: {
          installPhase =
            prev.installPhase
            + "chmod +x resources/app/node_modules/node-pty/build/Release/spawn-helper";
        })
      else x)
    prev.buildInputs;
  })
