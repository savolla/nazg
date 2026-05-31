{
  description = "nazg";

  inputs = {
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nixpkgs-25_11 = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    home-manager-25_11 = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-25_11";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-25_11";
    };
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      nixpkgs-25_11,
      home-manager-25_11,
      nix-on-droid,
      ...
    }:

    let
      mkStable =
        system:
        import nixpkgs-25_11 {
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
          modules = [ ./hosts/personal/physical/xkarna/configuration.nix ];
        };

        rpi3b = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            stable = mkStable "aarch64-linux";
            unstable = mkUnstable "aarch64-linux";
          };
          modules = [ ./hosts/personal/physical/rpi3b/configuration.nix ];
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
          home-manager-path = home-manager-25_11.outPath;
        };

      };

      # fiat runs Ubuntu — standalone home-manager only
      homeConfigurations = {
        fiat = home-manager-25_11.lib.homeManagerConfiguration {
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
