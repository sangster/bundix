# frozen_string_literal: true

RSpec.describe Bundix::Nix::Template do
  subject(:template) { described_class.new(template_path) }

  describe '#call' do
    subject(:nix_code) { template.call(template_vars) }

    let :template_vars do
      {
        project: 'test-project',
        ruby: 'test-ruby',
        gemfile: 'test-gemfile',
        lockfile: 'test-lockfile',
        gemset: 'test-gemset'
      }
    end

    context 'with the default flake.nix template' do
      let :template_path do
        Bundix::CommandLineOptions::FLAKE_NIX_TEMPLATES['default']
      end

      it 'renders flake.nix' do
        expect(nix_code).to eq <<~EXPECTED_NIX
          {
            description = "test-project";

            inputs = {
              nixpkgs.url = github:NixOS/nixpkgs;
              bundix.url = github:sangster/bundix;
            };

            outputs = { self, nixpkgs, bundix }:
              let
                pname = "test-project";
                system = "x86_64-linux";
                version = "0.0.1";
                pkgs = import nixpkgs {
                  inherit system;
                  overlays = [bundix.overlays.default];
                };

                gems = pkgs.bundixEnv {
                  inherit system;
                  name = "${pname}-${version}-bundler-env";
                  ruby = pkgs.test-ruby;
                  gemfile = ./test-gemfile;
                  lockfile = ./test-lockfile;
                  gemset = ./test-gemset;
                };
              in {
                packages.${system} = {
                  # Example package:
                  default = pkgs.stdenv.mkDerivation {
                    inherit gems pname version;
                    ruby = gems.wrappedRuby;
                    phases = "installPhase";
                    installPhase = ''
                      mkdir -p $out/bin
                      cat << EOF > "$out/bin/${pname}"
                      #!/bin/sh -e
                      exec $ruby/bin/ruby << RUBY
                      require 'bundler'
                      puts "Bundled rubygems:"
                      Bundler.setup.gems.map(&:name).sort.each do |gem|
                        puts " - \#{gem}"
                      end
                      RUBY
                      EOF
                      chmod +x "$out/bin/${pname}"
                    '';
                  };
                  bundled-gems = gems;
                };

                apps.${system} = {
                  bundix = { type = "app"; program = "${pkgs.bundix}/bin/bundix"; };
                };

                devShell.${system} = pkgs.mkShell {
                  buildInputs = [gems gems.wrappedRuby];
                };
              };
          }
        EXPECTED_NIX
      end
    end
  end
end
