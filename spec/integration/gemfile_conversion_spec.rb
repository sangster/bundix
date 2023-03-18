# frozen_string_literal: true

RSpec.describe 'Converting Gemfiles to gemset.nix' do
  shared_examples 'a gemset with' do |gem_platforms|
    gem_platforms.each do |platform, gems|
      gems.each do |gem, expected_version|
        it "gem '#{gem}', '#{expected_version}', platform: '#{platform}'" do
          expect(gemset.dig(:platforms, platform, gem, :version)).to eq expected_version
        end
      end
    end
  end

  describe 'extracting dependencies from Gemfile/Gemfile.lock' do
    include_context 'with gemset', spec_data_dir.join('bundler-audit')

    it_behaves_like 'a gemset with', 'ruby' => { 'bundler-audit' => '0.5.0',
                                                 'thor' => '0.19.4' }
  end

  describe 'extracting dependencies from .gemspec' do
    include_context 'with gemset', spec_data_dir.join('gemspec')

    it_behaves_like 'a gemset with', 'ruby' => { 'example' => '0.1.0',
                                                 'rubocop' => '1.45.1' }
  end

  describe 'trying to extract dependencies when the .gemspec is missing' do
    subject(:gemset) { gemset_builder.call }

    include_context 'with bundle', spec_data_dir.join('gemspec-missing')
    let(:gemset_builder) { Bundix::Gemset::Builder.new(definition) }

    it { expect { gemset }.to raise_error Bundler::Dsl::DSLError }
  end
end
