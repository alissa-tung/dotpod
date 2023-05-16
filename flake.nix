{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    priv.inputs.nixpkgs.follows = "nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    priv,
    disko,
    home-manager,
    hyprland,
  }: let
    privCfg = priv.privCfg;
    hostName = priv.privCfg.hostName;
    mainUser = "${privCfg.mainUser}";

    hostPlatform = "x86_64-linux";
    stateVersion = "23.05";
    pkgs = nixpkgs.legacyPackages.${hostPlatform};
  in {
    formatter."${hostPlatform}" =
      nixpkgs.legacyPackages."${hostPlatform}".alejandra;

    nixosConfigurations."${hostName}" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit privCfg;};

      system = "${hostPlatform}";
      modules = [
        ./nixos/configuration.nix
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager

        ({lib, ...}: {
          boot.kernelPackages = pkgs.linuxPackages_latest;
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = _: true;
          nixpkgs.hostPlatform = lib.mkDefault "${hostPlatform}";
          system.stateVersion = "${stateVersion}";
        })

        (let
          pkgs = import "${nixpkgs}" {
            system = "${hostPlatform}";
            config.allowUnfree = true;
            config.allowUnfreePredicate = _: true;
          };
        in {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${mainUser}" =
            import ./nixos/home.nix {inherit stateVersion pkgs;};
        })

        hyprland.nixosModules.default
        {programs.hyprland.enable = true;}
      ];
    };

    devShells."${hostPlatform}".default =
      import ./shell.nix {inherit pkgs;};

    installer = import ./installer.nix;
  };
}
