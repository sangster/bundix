# frozen_string_literal: true

RSpec.describe Bundix::Gemset::Builder do
  subject(:builder) { described_class.new(**options) }

  describe '.build' do
    subject(:builder) { described_class.build(**options) }

    let :other_options do
      { gemfile: 'gemfile', lockfile: 'lockfile' }
    end

    context 'when no platform is provided' do
      let(:options) { other_options }

      it { expect(builder).to be_a described_class }
    end

    context 'when a platform is provided' do
      let(:options) { other_options.merge(bundler_env_format: 'some-platform') }

      it { expect(builder).to be_a Bundix::Gemset::EnvFormatBuilder }
    end
  end

  describe '#call' do
    subject(:gemset) { builder.call }

    let(:mock_api) { instance_spy(Bundix::Gemset::Builder::RubyGemsApi) }

    before do
      allow(Bundix::Gemset::Builder::RubyGemsApi).to receive(:new).and_return(mock_api)
      allow(mock_api).to receive(:call).and_return(mock_rubygems_result)
    end

    context 'when using the "./bundler-audit/" test data' do
      let(:options) do
        {
          gemfile: 'spec/support/data/bundler-audit/Gemfile',
          lockfile: 'spec/support/data/bundler-audit/Gemfile.lock'
        }
      end

      let(:mock_rubygems_result) do
        [
          Bundler::EndpointSpecification.new(
            'bundler-audit', '0.5.0', 'ruby', nil,
            { 'bundler' => ['~> 1.2'], 'thor' => ['~> 0.18'] },
            checksum: ['2beb13862bd1ff50f953ac18297da675f5b4516dfef71c8da9473597aa9927bf'],
            ruby: '>= 1.9.3', rubygems: '>= 1.8.0'
          ),
          Bundler::EndpointSpecification.new(
            'thor', '0.19.4', 'ruby', nil, {},
            checksum: ['da8aa62e197c5c203d9dc3db06314abdab2d8dc9807d0094a9c0503cd36ec506'],
            ruby: '>= 1.8.7', rubygems: '>= 1.3.5'
          )
        ].tap { _1.each { |spec| spec.source = rubygems } }
      end
      let(:rubygems) { builder.lockfile_parser.sources.first }

      let :ruby_platform_gems do
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
                             platforms: { 'ruby' => ruby_platform_gems })
      end

      it 'queries the RubyGems API for all its dependencies' do
        gemset
        expect(mock_api).to have_received(:call).with(%w[bundler-audit thor])
      end
    end
  end
end
