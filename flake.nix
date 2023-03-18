{
  description = "Bundix makes it easy to package your Bundler-enabled Ruby applications with the Nix package manager";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default = final: prev:
        let
          pname = "bundix";
          src = ./.;
          lib = final.callPackage ./nix {};
          version = lib.extractBundixVersion ./lib/bundix/version.rb;
        in {
          bundix = final.callPackage ./nix/derivation.nix {
            inherit pname src version;
            runtimeInputs = with final; [
              git
              nix
              nix-prefetch-git
            ];
            gems = with final; bundixEnv {
              inherit pname ruby system;
              name = "${pname}-${version}-bundler-env";
              groups = ["default"];
              gemdir = ./.;
            };
          };
          bundixEnv = args: final.callPackage ./nix/bundixEnv.nix args;
        };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };
      in {
        packages = {
          default = pkgs.bundix;
          bundixEnv = pkgs.bundixEnv;
        };

        devShell =
          let
            dev-gems = with pkgs.bundix; gems.override {
              name = "${pname}-${version}-bundler-env-development";
              groups = null;
            };
          in pkgs.mkShell {
            buildInputs = with dev-gems; [basicEnv wrappedRuby];
            shellHook = "export BUNDIX_DEVELOPMENT=1";
          };
      }
    );
}
