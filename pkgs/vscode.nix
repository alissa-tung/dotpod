{pkgs, ...}:
pkgs.vscode-with-extensions.override {
  vscode = pkgs.vscode.overrideAttrs (_: prev: {
    postPatch =
      prev.postPatch
      + "chmod +x resources/app/node_modules/node-pty/build/Release/spawn-helper";
  });
  vscodeExtensions =
    (with pkgs.vscode-extensions; [
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
      pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {inherit (extension) name publisher version sha256;};
      })
    (import ../gen/vsc.nix).extensions;
}
