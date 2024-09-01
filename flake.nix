{
  description = "Flake basics described using the module system";

  inputs = {
    nixpkgs-lib.url = "https://github.com/NixOS/nixpkgs/archive/356624c12086a18f2ea2825fed34523d60ccc4e3.tar.gz"; # 12228ff1752d7b7624a54e9c1af4b222b3c1073b /lib from nixos-unstable
  };

  outputs = inputs@{ nixpkgs-lib, ... }:
    let
      lib = import ./lib.nix {
        inherit (nixpkgs-lib) lib;
        # Extra info for version check message
        revInfo =
          if nixpkgs-lib?rev
          then " (nixpkgs-lib.rev: ${nixpkgs-lib.rev})"
          else "";
      };
      templates = {
        default = {
          path = ./template/default;
          description = ''
            A minimal flake using flake-parts.
          '';
        };
        multi-module = {
          path = ./template/multi-module;
          description = ''
            A minimal flake using flake-parts.
          '';
        };
        unfree = {
          path = ./template/unfree;
          description = ''
            A minimal flake using flake-parts importing nixpkgs with the unfree option.
          '';
        };
        package = {
          path = ./template/package;
          description = ''
            A flake with a simple package:
            - Nixpkgs
            - callPackage
            - src with fileset
            - a check with runCommand
          '';
        };
      };
      flakeModules = {
        easyOverlay = ./extras/easyOverlay.nix;
        flakeModules = ./extras/flakeModules.nix;
        partitions = ./extras/partitions.nix;
      };
    in
    lib.mkFlake { inherit inputs; } {
      systems = [ ];
      imports = [ flakeModules.partitions ];
      partitionedAttrs.checks = "dev";
      partitionedAttrs.devShells = "dev";
      partitionedAttrs.herculesCI = "dev";
      partitions.dev.extraInputsFlake = ./dev;
      partitions.dev.module = {
        imports = [ ./dev/flake-module.nix ];
      };
      flake = {
        inherit lib templates flakeModules;
      };
    };

}
