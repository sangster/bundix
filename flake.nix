{
  description = "Bundix makes it easy to package your Bundler-enabled Ruby applications with the Nix package manager";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default = import ./nix/overlay.nix rec {
        pname = "bundix";
        src = ./.;
        extraConfigPaths = [
          "${./.}/lib" # .gemspec file references `Bundix::Version`
          "${./.}/${pname}.gemspec"
        ];
        versionRubyFile = ./lib/bundix/version.rb;
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
