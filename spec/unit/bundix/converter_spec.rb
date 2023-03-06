# frozen_string_literal: true

RSpec.describe Bundix::Converter do
  subject(:converter) { described_class.new(**options) }

  describe '#call' do
    subject(:gemset) { converter.call }

    context 'when using the "./bundler-audit/" test data' do
      let(:options) { { gemfile: gemfile, lockfile: lockfile } }
      let(:gemfile) { 'spec/support/data/bundler-audit/Gemfile' }
      let(:lockfile) { 'spec/support/data/bundler-audit/Gemfile.lock' }

      let :expected_bundler_audit do
        {
          version: '0.5.0',
          source: {
            type: 'gem',
            remotes: ['https://rubygems.org'],
            sha256: '1gr7k6m9fda7m66irxzydm8v9xbmlryjj65cagwm1zyi5f317srb'
          },
          platforms: [],
          groups: [:default],
          'dependencies' => ['thor']
        }
      end

      let :expected_thor do
        {
          version: '0.19.4',
          source: {
            type: 'gem',
            remotes: ['https://rubygems.org'],
            sha256: '01n5dv9kql60m6a00zc0r66jvaxx98qhdny3klyj0p3w34pad2ns'
          },
          platforms: [],
          groups: [:default]
        }
      end

      it 'generates the expected gemset.nix contents' do
        expect(gemset).to eq 'bundler-audit' => expected_bundler_audit,
                             'thor' => expected_thor
      end
    end
  end

  describe '#parse_gemset' do
    subject(:gemset) { converter.parse_gemset }

    context 'when using the "./path with space/" test data' do
      let(:options) { { gemset: gemset_file } }
      let(:gemset_file) { 'spec/support/data/path with space/gemset.nix' }

      it { expect(gemset).to eq 'a' => 1 }
    end
  end
end
