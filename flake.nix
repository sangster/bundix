{
  description = "Bundix makes it easy to package your Bundler-enabled Ruby applications with the Nix package manager";

  inputs = {
    # nixpkgs needs to be 22.11, or newer. `bundlerEnv.extraConfigPaths` is
    # required to include the *.gemspec file.
    nixpkgs.url = "github:NixOS/nixpkgs?ref=22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "bundix";
        pkgs = import nixpkgs { inherit system; };

        gems = with pkgs; bundlerEnv {
          inherit name ruby;
          gemdir = ./.;
          extraConfigPaths = [
            "${./.}/lib" # .gemspec file references `Bundix::Version`
            "${./.}/${name}.gemspec"
          ];
        };

        upstream-package = import ./default.nix {
          inherit pkgs;
          inherit (gems) ruby;
        };
        bundled-package = upstream-package.overrideAttrs (_old: {
          # See https://nixos.wiki/wiki/Packaging/Ruby#Build_default.nix
          installPhase = ''
            mkdir -p $out/{bin,share/${name}}
            cp -r $src/* $out/share/${name}
            bin=$out/bin/${name}
            cat > $bin <<EOF
            #!/bin/sh -e
            exec ${gems}/bin/bundle exec \
              ${gems.ruby}/bin/ruby \
              $out/share/${name}/bin/${name} "\$@"
            EOF
            chmod +x $bin
          '';
        });
      in {
        packages = {
          default = bundled-package;
          gems = gems;
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            gems
            gems.ruby
          ];
        };
      }
    );
}
