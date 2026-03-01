{
  description = "Cross-platform home-manager modules (Nix flake)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      # Systems to generate outputs for
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # Main home-manager module (cross-platform non-AI config)
      homeManagerModules.default = {
        imports = [
          ./modules/home-manager/common.nix
          ./modules/home-manager/tmux.nix
          ./modules/monitoring
        ];
      };

      # Python packages overlay
      overlays.default = import ./overlays/python-packages.nix;

      # Quality checks (formatting, linting, dead code)
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./lib/checks.nix {
          inherit pkgs nixpkgs home-manager;
          src = ./.;
          homeModule = self.homeManagerModules.default;
        }
      );

      # Development shells
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
              statix
              deadnix
              treefmt
            ];
          };
        }
      );

      # Formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
