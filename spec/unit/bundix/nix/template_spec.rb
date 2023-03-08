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

    context 'with the default shell.nix template' do
      let :template_path do
        Bundix::CommandLineOptions::FLAKE_NIX_TEMPLATES['default']
      end

      it 'renders bundlerEnv nix code' do
        expect(nix_code).to eq <<~EXPECTED_NIX
          {
            description = "test-project";

            inputs = {
              nixpkgs.url = github:NixOS/nixpkgs;
            };

            outputs = { self, nixpkgs }:
              let
                name = "test-project";
                system = "x86_64-linux";
                version = "0.0.1";
                pkgs = import nixpkgs { inherit system; };

                gems = pkgs.bundlerEnv {
                  name = "${pname}-${version}-bundler-env";
                  ruby = pkgs.test-ruby;
                  gemfile = ./test-gemfile;
                  lockfile = ./test-lockfile;
                  gemset = ./test-gemset;
                };
              in {
                packages.${system} = {
                  default = stdenv.mkDerivation {
                    inherit pname version;
                    buildInputs = [
                      gems
                      gems.ruby
                    ];
                  };
                  gems = gems;
                };

                devShell.${system} = pkgs.mkShell {
                  buildInputs = [
                    gems
                    gems.ruby
                  ];
                };
              };
          }
        EXPECTED_NIX
      end
    end
  end
end
