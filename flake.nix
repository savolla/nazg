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
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      nixpkgs-25_11,
      home-manager-25_11,
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

        fiat = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            stable = mkStable "x86_64-linux";
            unstable = mkUnstable "x86_64-linux";
            inherit home-manager-25_11;
          };
          modules = [ ./hosts/work/kartaca/physical/fiat/configuration.nix ];
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
    };
}
