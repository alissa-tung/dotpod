{
  lib,
  privCfg,
  config,
  pkgs,
  ...
}: let
  vscode = with pkgs;
    vscode-with-extensions.override {
      vscodeExtensions =
        (with vscode-extensions; [
          ms-vscode-remote.remote-ssh
          llvm-vs-code-extensions.vscode-clangd
          rust-lang.rust-analyzer
          haskell.haskell
          jnoortheen.nix-ide
          tamasfe.even-better-toml
          justusadam.language-haskell
        ])
        ++ map (extension:
          vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {inherit (extension) name publisher version sha256;};
          })
        (import ../gen/vsc.nix).extensions;
    };

  xmobar = (import ../pkgs/xmobar.nix) {inherit pkgs;};
in {
  imports = [
    ./hardware-configuration.nix

    ./disks.nix
  ];

  services.xserver.dpi = 144;
  services.xserver.deviceSection = lib.mkDefault ''Option "TearFree" "true"'';

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "${privCfg.hostName}";
  networking.wireless.iwd.enable = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  services.picom.enable = true;
  services.xserver = {
    enable = true;
    libinput.enable = true;

    windowManager = {
      xmonad = {
        enable = true;
        extraPackages = haskellPackages: [haskellPackages.xmonad-contrib];
        config = builtins.readFile ../cfg/xmonad.hs;
      };
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  programs.zsh = {
    enable = true;
    promptInit = lib.mkForce "";
    interactiveShellInit =
      ''
        source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
      ''
      + builtins.readFile ../cfg/.zshrc;
  };

  users.mutableUsers = false;
  users.users.root.password = "${privCfg.rootPasswd}";
  users.users."${privCfg.mainUser}" = {
    password = "${privCfg.mainPasswd}";
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    packages = [vscode] ++ (with pkgs; [firefox]);
  };

  environment.systemPackages = with pkgs; [
    python3
    git
    gnumake
    ormolu
    nixfmt
    xmobar
    fd
    jq
    ripgrep
    bottom
    light
    (kitty.overridePythonAttrs (_: {doCheck = false;}))
    rnix-lsp
    nixpkgs-fmt
    alejandra
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-extra
    noto-fonts-emoji
    fira-code
    sarasa-gothic
  ];

  services.openssh.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.autoUpgrade.channel = "https://mirrors.bfsu.edu.cn/nix-channels/nixos-unstable/";
  nix.settings.substituters = lib.mkForce [
    "https://mirrors.bfsu.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"

    "https://cache.nixos.org/"
  ];

  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [fcitx5-chinese-addons];
}
