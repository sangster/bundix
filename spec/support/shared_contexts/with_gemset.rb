# frozen_string_literal: true

RSpec.shared_context 'with gemset' do |options|
  let(:gemset_builder) { Bundix::Gemset::Builder.new(**options) }
  let(:gemset) { gemset_builder.call }
  let :gemset_sources do
    gemset_builder.definition
                  .locked_gems
                  .specs
                  .map { Bundix::Nix::BundlerSource.build(_1) }
  end
  let :gemset_platforms do
    Hash
      .new { |hash, key| hash[key] = {} }
      .tap do |platforms|
        gemset_builder.definition.locked_gems.specs.each do |spec|
          platforms[spec.platform.to_s][spec.name] = {
            dependencies: spec.dependencies.map(&:name),
            groups: ['default'],
            source: Bundix::Nix::BundlerSource.build(spec).to_nix,
            version: spec.version.to_s
          }
        end
      end
  end

  let :sha256 do
    '5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03'
  end

  before do
    allow(Bundix::Nix::BundlerSource::Git).to receive(:sha256).and_return(sha256)
    allow(Bundix::Nix::BundlerSource::Rubygems).to receive(:sha256).and_return(sha256)
    allow(gemset_builder).to receive(:platforms) { gemset_platforms }
  end
end
