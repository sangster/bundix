# frozen_string_literal: true

RSpec.describe 'Converting Gemfiles to gemset.nix' do
  describe 'extracting dependencies from Gemfile/Gemfile.lock' do
    include_context 'with gemset',
                    gemfile: File.expand_path('../support/data/bundler-audit/Gemfile', __dir__),
                    lockfile: File.expand_path('../support/data/bundler-audit/Gemfile.lock', __dir__)

    it { expect(gemset.dig('bundler-audit', :version)).to eq '0.5.0' }
    it { expect(gemset.dig('thor', :version)).to eq '0.19.4' }
  end

  describe 'extracting dependencies from .gemspec' do
    include_context 'with gemset',
                    gemfile: File.expand_path('../support/data/gemspec/Gemfile', __dir__),
                    lockfile: File.expand_path('../support/data/gemspec/Gemfile.lock', __dir__)

    it { expect(gemset.dig('example', :version)).to eq '0.1.0' }
    it { expect(gemset.dig('rubocop', :version)).to eq '1.45.1' }
  end


  describe 'trying to extract dependencies when the .gemspec is missing' do
    include_context 'with gemset',
                    gemfile: File.expand_path('../support/data/gemspec-missing/Gemfile', __dir__),
                    lockfile: File.expand_path('../support/data/gemspec-missing/Gemfile.lock', __dir__)

    it { expect { gemset }.to raise_error Bundler::Dsl::DSLError }
  end
end
