{
  lib,
  privCfg,
  pkgs,
  ...
}: let
  dpi = 144;

  utils = import ../utils.nix;

  vscode = import ../pkgs/vscode.nix {inherit pkgs;};
  xmobar = import ../pkgs/xmobar.nix {inherit pkgs;};
  sharedResources = utils.sharedResources pkgs;
in {
  systemd.services.nix-daemon.environment = {
    https_proxy = "http://127.0.0.1:7995";
    http_proxy = "http://127.0.0.1:7995";
  };

  networking.firewall.enable = false;

  imports = [
    ./hardware-configuration.nix

    ./disks.nix
  ];

  services.btrfs.autoScrub.enable = true;
  services.fstrim.enable = true;

  services.xserver.dpi = dpi;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
    Xft.dpi: ${builtins.toString dpi}
    EOF
  '';

  services.xserver.deviceSection = lib.mkDefault ''Option "TearFree" "true"'';

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "${privCfg.hostName}";
  networking.wireless.iwd.enable = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    enable = true;
    libinput.enable = true;

    windowManager = {
      xmonad = {
        enable = true;
        extraPackages = haskellPackages: [haskellPackages.xmonad-contrib];
        config =
          sharedResources.replaceBackgroundImageString
          (builtins.readFile ../cfg/xmonad.hs);
      };
    };
  };

  services.smartd.enable = true;

  programs.steam.enable = true;

  services.xserver.displayManager.lightdm = {
    enable = true;
    background = sharedResources.backgroundImagePath;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  programs.zsh = {
    enable = true;
    promptInit = lib.mkForce "";
    interactiveShellInit =
      ''
        export GRML_DISPLAY_BATTERY=1
        source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
      ''
      + builtins.readFile ../cfg/.zshrc;

    autosuggestions = {enable = true;};
    syntaxHighlighting = {enable = true;};
  };

  programs.bash.interactiveShellInit = ''
    eval "$(starship init bash)"
  '';

  users.mutableUsers = false;
  users.users.root.password = "${privCfg.rootPasswd}";
  users.users."${privCfg.mainUser}" = {
    password = "${privCfg.mainPasswd}";
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
    packages =
      [vscode]
      ++ (with pkgs; [
        firefox
        chromium
        flutter
        rustup
        cargo-edit
        cargo-hakari
        cargo-binutils
        cargo-make
        elan
        gcc
        chez
        docker-compose
        sqlite
        wpsoffice
        filelight
        qq
        obsidian
        logseq
        yamlfmt
        yuzu
      ]);
  };

  environment.systemPackages =
    (with pkgs; [
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
      kitty
      nil
      alejandra
      feh
      unzip
      unar
      black
      pylint
      erlfmt
      erlang-ls
      starship
      gwenview
      deno
      tree
      obs-studio
      protobuf
      jdk11_headless
      xdg-desktop-portal
      ormolu

      clash-verge
    ])
    ++ (with pkgs.jetbrains; [idea-ultimate goland])
    ++ (with pkgs; [(agda.withPackages [agdaPackages.standard-library])])
    ++ (with pkgs; [
      (haskellPackages.ghcWithPackages
        (ghcPkgs: with ghcPkgs; [haskell-language-server cabal-install]))
    ])
    ++ (with pkgs.haskellPackages; [cabal-fmt]);

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-extra
    noto-fonts-emoji
    fira-code
    sarasa-gothic

    roboto-mono
    nerdfonts
  ];

  services.openssh.enable = true;

  nix.settings.experimental-features = utils.experimentalFeatures;

  system.autoUpgrade.channel = "https://mirrors.bfsu.edu.cn/nix-channels/nixos-unstable/";
  nix.settings.substituters = lib.mkForce utils.mirrors;

  services.xserver.libinput.touchpad.disableWhileTyping = true;

  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [fcitx5-chinese-addons];

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    daemon.settings = {
      "registry-mirrors" = ["http://f1361db2.m.daocloud.io"];
    };
  };
}
