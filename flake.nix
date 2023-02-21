{
  description = "Bundix makes it easy to package your Bundler-enabled Ruby applications with the Nix package manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        gems = with pkgs; bundlerEnv {
          name = "bundix";
          inherit ruby;
          gemdir = ./.;
        };
      in {
        packages = {
          default = import ./default.nix { inherit pkgs; };
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            gems
            pkgs.ruby
          ];
        };
      }
    );
}
