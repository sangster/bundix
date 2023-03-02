# frozen_string_literal: true

RSpec.describe Bundix::CommandLine do
  subject(:cmd) { described_class.new(**options) }

  let(:options) { {} }

  describe '#shell_nix_string' do
    subject(:nix) { cmd.shell_nix_string }

    let :options do
      {
        project: 'test-project',
        ruby: 'test-ruby',
        gemfile: 'test-gemfile',
        lockfile: 'test-lockfile',
        gemset: 'test-gemset'
      }
    end

    it 'renders bundlerEnv nix code' do
      expect(nix).to eq <<~EXPECTED_NIX
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
