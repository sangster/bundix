# frozen_string_literal: true

RSpec.describe Bundix::Nix::BundlerSource do
  describe '.build' do
    subject(:source) { described_class.build(spec) }

    let(:spec) { Struct.new(:source).new(spec_source) }

    context 'with a Bundler::Source::Git' do
      let(:spec_source) { Bundler::Source::Git.new({}) }

      it { expect(source).to be_a described_class::Git }
    end

    context 'with a Bundler::Source::Path' do
      let(:spec_source) { Bundler::Source::Path.new({}) }

      it { expect(source).to be_a described_class::Path }
    end

    context 'with a Bundler::Source::Rubygems' do
      let(:spec_source) { Bundler::Source::Rubygems.new({}) }

      it { expect(source).to be_a described_class::Rubygems }
    end

    context 'with an unexpected source' do
      let(:spec_source) { Object.new }

      it { expect { source }.to raise_error ArgumentError }
    end
  end
end
