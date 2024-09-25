{
  inputs = {
    # change to github:nixos/nixpkgs/nixos-unstable for unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      # change to github:nix-community/home-manager for unstable
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations = {
        # update with `nix flake update`
        # rebuild by cd-ing into flake directory and running `nixos-rebuild switch --flake .#nixos`
        nixos =
          let
            user = "chris";
            host = "nixos";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            specialArgs = {
              inherit (nixpkgs) lib;
              inherit
                inputs
                host
                user
                ;
            };

            modules = [
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${user} = {
                    imports = [
                      ./home.nix
                    ];

                    home = {
                      username = user;
                      homeDirectory = "/home/${user}";
                      # do not change this value
                      stateVersion = "24.05";
                    };

                    # Let Home Manager install and manage itself.
                    programs.home-manager.enable = true;
                  };
                };
              }
              ./configuration.nix
              ./hardware-configuration.nix
            ];
          };
      };
    };
}
