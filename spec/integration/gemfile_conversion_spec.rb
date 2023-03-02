# frozen_string_literal: true

RSpec.describe 'Converting Gemfiles to gemset.nix' do
  shared_examples 'a gemset with' do |gems|
    gems.each do |gem, expected_version|
      it "gem '#{gem}', '#{expected_version}'" do
        expect(gemset.dig(gem, :version)).to eq expected_version
      end
    end
  end

  describe 'extracting dependencies from Gemfile/Gemfile.lock' do
    include_context 'with gemdir', spec_data_dir.join('bundler-audit')

    it_behaves_like 'a gemset with', 'bundler-audit' => '0.5.0',
                                     'thor' => '0.19.4'
  end

  describe 'extracting dependencies from .gemspec' do
    include_context 'with gemdir', spec_data_dir.join('gemspec')

    it_behaves_like 'a gemset with', 'example' => '0.1.0',
                                     'rubocop' => '1.45.1'
  end

  describe 'trying to extract dependencies when the .gemspec is missing' do
    include_context 'with gemdir', spec_data_dir.join('gemspec-missing')

    it { expect { gemset }.to raise_error Bundler::Dsl::DSLError }
  end
end
