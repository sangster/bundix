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

        upstream-package = import ./default.nix {
          inherit pkgs;
          inherit (gems) ruby;
        };
        bundled-package = upstream-package.overrideAttrs (_old: {
          # See https://nixos.wiki/wiki/Packaging/Ruby#Build_default.nix
          installPhase = ''
            mkdir -p $out/{bin,share/bundix}
            cp -r $src/* $out/share/bundix
            bin=$out/bin/bundix
            cat > $bin <<EOF
            #!/bin/sh -e
            exec ${gems}/bin/bundle exec ${gems.ruby}/bin/ruby $out/share/bundix/bin/bundix "\$@"
            EOF
            chmod +x $bin
          '';
        });
      in {
        packages.default = bundled-package;

        devShell = pkgs.mkShell {
          buildInputs = [
            gems
            gems.ruby
          ];
        };
      }
    );
}
