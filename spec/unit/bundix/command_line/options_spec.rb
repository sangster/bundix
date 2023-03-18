# frozen_string_literal: true

require 'tempfile'

RSpec.describe Bundix::CommandLine::Options do
  subject(:opt_parser) { described_class.new }

  let(:defaults) { Bundix::DEFAULT_OPTIONS }

  describe '#parse' do
    subject(:options) { opt_parser.parse(argv) && opt_parser.options }

    context 'with no CLI flags' do
      let(:argv) { [] }

      it 'returns the default options' do
        expect(options).to eq defaults
      end
    end

    describe 'Input/output options' do
      context 'with --gemfile' do
        let(:argv) { %w[--gemfile=../some/relative/Gemfile] }

        it { expect(options[:gemfile]).to be_a(Pathname) }
        it { expect(options[:gemfile]).to be_absolute }
      end

      context 'with --lockfile' do
        let(:argv) { %w[--lockfile=../some/relative/Gemfile.lock] }

        it { expect(options[:lockfile]).to be_a(Pathname) }
        it { expect(options[:lockfile]).to be_absolute }
      end

      context 'with --gemset' do
        let(:argv) { %w[--gemset=../some/relative/gemset.nix] }

        it { expect(options[:gemset]).to be_a(Pathname) }
        it { expect(options[:gemset]).to be_absolute }
      end

      context 'with --bundler-env' do
        context 'with no value' do
          let(:argv) { %w[--bundler-env] }

          it { expect(options[:bundler_env_format]).to eq defaults[:ruby_platform] }
        end

        context 'with some value' do
          let(:argv) { %w[--bundler-env=some-value] }

          it { expect(options[:bundler_env_format]).to eq 'some-value' }
        end
      end

      context 'with --update' do
        context 'with no value' do
          let(:argv) { %w[--update] }

          it { expect(options[:update]).to be true }
        end

        context 'with a list of gems' do
          let(:argv) { %w[--update=1,2,3] }

          it do
            expect(options[:update]).to contain_exactly '1', '2', '3'
          end
        end
      end

      context 'with --bundle-cache' do
        context 'with no value' do
          let(:argv) { %w[--bundle-cache] }

          it { expect(options[:cache]).to be_a(Pathname) }
          it { expect(options[:cache]).to be_absolute }
          it { expect(options[:cache].to_s).to end_with defaults[:bundle_cache_path][2..] }
        end

        context 'with some value' do
          let(:argv) { %w[--bundle-cache=path] }

          it { expect(options[:cache]).to be_a(Pathname) }
          it { expect(options[:cache]).to be_absolute }
          it { expect(options[:cache].to_s).to end_with '/path' }
        end
      end

      context 'with --init' do
        context 'with no value' do
          let(:argv) { %w[--init] }

          it { expect(options[:init]).to eq defaults[:ruby_derivation] }
        end

        context 'with some value' do
          let(:argv) { %w[--init=jruby] }

          it { expect(options[:init]).to eq 'jruby' }
        end
      end

      context 'with --init-template' do
        context 'with an unknown value' do
          let(:argv) { %w[--init-template=unknown_value] }

          it { expect { options }.to raise_error OptionParser::InvalidArgument }
        end

        context 'with a named template' do
          let(:argv) { ["--init-template=#{template.first}"] }
          let(:template) { Bundix::FLAKE_NIX_TEMPLATES.entries.last }

          it { expect(options[:init_template]).to eq template.last }
        end

        context 'with a filename' do
          let(:argv) { ["--init-template=#{template.path}"] }
          let(:template) { Tempfile.new(%w[template- .nix.erb]) }

          around do |test|
            test.call
          ensure
            template.unlink
          end

          it { expect(options[:init_template]).to eq Pathname(template.path) }
        end
      end
    end
  end
end
