{
  mirrors = [
    "https://mirrors.bfsu.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"

    "https://cache.nixos.org/"
  ];
  experimentalFeatures = ["nix-command" "flakes" "repl-flake"];

  sharedResources = pkgs: let
    sharedResources = import ./pkgs/shared-resources.nix {inherit pkgs;};
  in rec {
    inherit (sharedResources) outPath;

    backgroundImagePath = "${outPath}/bgi.jpg";

    replaceBackgroundImageString = inputString:
      builtins.replaceStrings ["__BACKGROUND_IMAGE__"]
      [backgroundImagePath]
      inputString;
  };
}
