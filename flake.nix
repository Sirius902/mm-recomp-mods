{
  description = "MMRecompInputLag flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [(import ./nix/pkgs/overlay.nix)];
        };

        nativeBuildInputs = [
          pkgs.gnumake
          pkgs.zip
          pkgs.unzip
          pkgs.n64recomp
          pkgs.llvmPackages.clang-unwrapped
          pkgs.llvmPackages.lld
        ];
      in {
        formatter = pkgs.alejandra;

        packages =
          import ./nix/pkgs/all-packages.nix {inherit pkgs;}
          // {
            build = pkgs.writeShellApplication {
              name = "build";
              runtimeInputs = nativeBuildInputs;
              text = ''
                make -j"$NIX_BUILD_CORES"
                exec RecompModTool ./mod.toml ./build/
              '';
            };

            clean = pkgs.writeShellScriptBin "clean" ''
              rm -r ./build/
            '';
          };

        devShells.default = pkgs.mkShell.override {stdenv = pkgs.stdenvNoCC;} {
          buildInputs = nativeBuildInputs ++ [pkgs.clang-tools];
        };
      };
    };
}
