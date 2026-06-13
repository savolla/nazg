{
  description = "nazg";

  inputs = {
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    stable = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "stable";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "stable";
    };
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      stable,
      home-manager-stable,
      nix-on-droid,
      ...
    }:

    let
      mkStable =
        system:
        import stable {
          inherit system;
          config.allowUnfree = true;
        };
      mkUnstable =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      nixosConfigurations = {

        xkarna = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            stable = mkStable "x86_64-linux";
            unstable = mkUnstable "x86_64-linux";
          };
          modules = [ ./hosts/personal/desktop/xkarna/configuration.nix ];
        };

        rpi3b = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            stable = mkStable "aarch64-linux";
            unstable = mkUnstable "aarch64-linux";
          };
          modules = [ ./hosts/personal/embedded/rpi3b/configuration.nix ];
        };

      };

      # samsung galaxy a24 uses termux via nix-on-droid
      nixOnDroidConfigurations = {

        a24 = nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = mkStable "aarch64-linux";
          modules = [ ./hosts/personal/mobile/a24/default.nix ];
          extraSpecialArgs = {
            stable = mkStable "aarch64-linux";
          };
          home-manager-path = home-manager-stable.outPath;
        };

      };

      # fiat runs Ubuntu — standalone home-manager only
      homeConfigurations = {
        fiat = home-manager-stable.lib.homeManagerConfiguration {
          pkgs = mkStable "x86_64-linux";
          extraSpecialArgs = {
            stable = mkStable "x86_64-linux";
            unstable = mkUnstable "x86_64-linux";
          };
          modules = [ ./hosts/work/kartaca/laptop/fiat/home.nix ];
        };
      };
    };
}
