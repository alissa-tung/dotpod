{pkgs, ...}:
pkgs.vscode-with-extensions.override {
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
      denoland.vscode-deno
      redhat.vscode-yaml
      ms-azuretools.vscode-docker
      ms-vscode.cmake-tools
    ])
    ++ map (extension:
      pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {inherit (extension) name publisher version sha256;};
      })
    (import ../gen/vsc.nix).extensions;
}
