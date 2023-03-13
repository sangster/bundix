# frozen_string_literal: true

RSpec.describe Bundix::Gemset::Builder do
  subject(:builder) { described_class.new(**options) }

  describe '#call' do
    subject(:gemset) { builder.call }

    context 'when using the "./bundler-audit/" test data' do
      let(:options) { { gemfile: gemfile, lockfile: lockfile } }
      let(:gemfile) { 'spec/support/data/bundler-audit/Gemfile' }
      let(:lockfile) { 'spec/support/data/bundler-audit/Gemfile.lock' }

      let :ruby_gems do
        {
          'bundler-audit' => {
            version: '0.5.0',
            source: {
              type: 'gem',
              remotes: ['https://rubygems.org'],
              sha256: '1gr7k6m9fda7m66irxzydm8v9xbmlryjj65cagwm1zyi5f317srb'
            },
            groups: ['default'],
            dependencies: ['thor']
          },
          'thor' => {
            version: '0.19.4',
            source: {
              type: 'gem',
              remotes: ['https://rubygems.org'],
              sha256: '01n5dv9kql60m6a00zc0r66jvaxx98qhdny3klyj0p3w34pad2ns'
            },
            groups: ['default']
          }
        }
      end

      it 'generates the expected gemset.nix contents' do
        expect(gemset).to eq(dependencies: %w[bundler-audit],
                             platforms: { 'ruby' => ruby_gems })
      end
    end
  end
end
