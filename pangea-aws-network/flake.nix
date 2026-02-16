{
  description = "pangea-aws-network gem";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.ruby-nix.url = "github:inscapist/ruby-nix";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, ruby-nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ruby-nix.overlays.ruby ];
      };
      rnix = ruby-nix.lib pkgs;
      rnix-env = rnix {
        name = "pangea-aws-network";
        gemset = ./gemset.nix;
      };
    in {
      packages.default = rnix-env.env;
      devShells.default = pkgs.mkShell {
        buildInputs = [ rnix-env.env rnix-env.ruby ];
      };
    });
}