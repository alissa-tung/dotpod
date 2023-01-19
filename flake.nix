{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

  outputs = { self, nixpkgs, priv, disko, home-manager }@inputs:
    let
      privCfg = priv.privCfg;
      hostName = priv.privCfg.hostName;
      mainUser = "${privCfg.mainUser}";

      hostPlatform = "x86_64-linux";
      stateVersion = "23.05";
      pkgs = nixpkgs.legacyPackages.${hostPlatform};
    in
    {
      formatter."${hostPlatform}" =
        nixpkgs.legacyPackages."${hostPlatform}".nixpkgs-fmt;

      nixosConfigurations."${hostName}" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit privCfg; };

        system = "${hostPlatform}";
        modules = [
          ./nixos/configuration.nix
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager

          ({ lib, ... }: {
            boot.kernelPackages = pkgs.linuxPackages_latest;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.hostPlatform = lib.mkDefault "${hostPlatform}";
            system.stateVersion = "${stateVersion}";
          })

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${mainUser}" =
              (import ./nixos/home.nix) { inherit stateVersion; };
          }
        ];
      };

      devShells."${hostPlatform}".default =
        import ./shell.nix { inherit pkgs; };

      installer = import ./installer.nix;
    };
}
