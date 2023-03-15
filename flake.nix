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

          gems = with final; bundixEnv {
            inherit pname ruby system;
            name = "${pname}-${version}-bundler-env";
            gemdir = src;
          };

          bundix = final.callPackage ./nix/derivation.nix {
            inherit gems pname src version;
            runtimeInputs = with final; [
              git
              nix
              nix-prefetch-git
            ];
          };
        in {
          inherit bundix;
          bundixEnv = args: final.bundlerEnv (args // lib.platformGemset args);
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

        devShell = pkgs.mkShell {
          buildInputs = with pkgs.bundix; [gems gems.ruby];
        };
      }
    );
}
