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
      let(:template_path) { Bundix::SHELL_NIX_TEMPLATE }

      it 'renders bundlerEnv nix code' do
        expect(nix_code).to eq <<~EXPECTED_NIX
          with (import <nixpkgs> {});
          let
            env = bundlerEnv {
              name = "test-project-bundler-env";
              inherit test-ruby;
              gemfile  = ./test-gemfile;
              lockfile = ./test-lockfile;
              gemset   = ./test-gemset;
            };
          in stdenv.mkDerivation {
            name = "test-project";
            buildInputs = [ env ];
          }
        EXPECTED_NIX
      end
    end
  end
end
