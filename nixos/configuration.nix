{
  lib,
  privCfg,
  config,
  pkgs,
  ...
}: let
  dpi = 144;

  utils = import ../utils.nix;

  xmobar = import ../pkgs/xmobar.nix {inherit pkgs;};
  sharedResources = utils.sharedResources pkgs;
in {
  imports = [
    ./hardware-configuration.nix

    ./disks.nix
  ];

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

  services.picom = {
    enable = true;
    backend = "glx";
  };

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
        source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
      ''
      + builtins.readFile ../cfg/.zshrc;

    autosuggestions = {enable = true;};
  };

  programs.bash.interactiveShellInit = ''
    eval "$(starship init bash)"
  '';

  users.mutableUsers = false;
  users.users.root.password = "${privCfg.rootPasswd}";
  users.users."${privCfg.mainUser}" = {
    password = "${privCfg.mainPasswd}";
    isNormalUser = true;
    extraGroups = ["wheel"];
    packages = with pkgs; [firefox rustup cargo-edit cargo-hakari];
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
    kitty
    nil
    alejandra
    feh
    unzip
    black
    pylint
    erlfmt
    erlang-ls
    starship
    gwenview
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-extra
    noto-fonts-emoji
    fira-code
    sarasa-gothic

    roboto-mono
  ];

  services.openssh.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.autoUpgrade.channel = "https://mirrors.bfsu.edu.cn/nix-channels/nixos-unstable/";
  nix.settings.substituters = lib.mkForce utils.mirrors;

  services.xserver.libinput.touchpad.disableWhileTyping = true;

  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [fcitx5-chinese-addons];

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };
}
