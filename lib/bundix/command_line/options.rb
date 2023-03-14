# frozen_string_literal: true

require 'optparse'

module Bundix
  class CommandLine
    # Parses commandline options.
    class Options < OptionParser # rubocop:disable Metrics/ClassLength
      FLAKE_NIX_TEMPLATES = {
        'default' => TEMPLATES.join('flake-nix/default.nix.erb'),
        'flake-utils' => TEMPLATES.join('flake-nix/flake-utils.nix.erb')
      }.transform_values { |path| Pathname(__dir__).join(path).freeze }.freeze

      DEFAULTS = {
        bundle_cache_path: './vendor/bundle',
        gemfile: './Gemfile',
        gemset: './gemset.nix',
        ignore_config: false,
        init_template: FLAKE_NIX_TEMPLATES['default'],
        lockfile: './Gemfile.lock',
        project: File.basename(Dir.pwd),
        ruby_derivation: 'ruby',
        ruby_platform: 'ruby',
        skip_gemset: false
      }.freeze

      LOCAL_PLATFORM = Gem::Platform.local.to_s.freeze

      attr_accessor :options

      def initialize
        @options = DEFAULTS.dup
        super { |opts| make_options(opts) }
      end

      private

      def make_options(opts)
        logging_options(opts)

        opts.separator("\nInput/Output files:")
        input_file_options(opts)
        output_file_options(opts)

        opts.separator("\nBundler utilities:")
        bundle_options(opts)

        opts.separator("\nflake.nix creation:")
        init_options(opts)

        opts.separator("\nBundix environment:")
        command_options(opts)
      end

      def logging_options(opts)
        opts.on '-q', '--quiet', 'only output errors' do
          options[:quiet] = true
        end
      end

      def input_file_options(opts)
        opts.on '--gemfile=PATH', "path to the existing Gemfile #{default :gemfile}" do |value|
          options[:gemfile] = File.expand_path(value)
        end

        opts.on '--lockfile=PATH', "path to the Gemfile.lock #{default :lockfile}" do |value|
          options[:lockfile] = File.expand_path(value)
        end
      end

      def output_file_options(opts)
        opts.on '--gemset=PATH', "destination path of the gemset.nix #{default :gemset}" do |value|
          options[:gemset] = File.expand_path(value)
        end

        opts.on '--bundler-env[=PLATFORM]',
                "export a nixpkgs#bundlerEnv compatible gemset #{default :ruby_platform}" do |platform|
          options[:bundler_env_format] = platform || DEFAULTS[:ruby_platform]
        end

        opts.on '--skip-gemset', 'do not generate gemset' do
          options[:skip_gemset] = true
        end
      end

      def parse_template(template)
        if FLAKE_NIX_TEMPLATES.key?(template)
          FLAKE_NIX_TEMPLATES[template]
        elsif File.readable?(template)
          template
        else
          raise OptionParser::InvalidArgument, "--init-template=#{template}"
        end
      end

      def bundle_options(opts) # rubocop:disable Metrics/MethodLength
        opts.on '-l', '--lock', 'lock the gemfile gems into the lockfile' do
          options[:lock] = true
        end

        opts.on '-u', '--update[=GEMS]',
                'update the lockfile with new versions of the specified ' \
                'gems, or each one, if none given (implies --lock)' do |gems|
          options[:update_lock] = gems || true
        end

        opts.on '-c', '--bundle-cache[=DIRECTORY]',
                "package .gem files into directory #{default :bundle_cache_path}" do |dir|
          options[:cache] = dir || DEFAULTS[:bundle_cache_path]
        end

        opts.on '--ignore-bundler-configs', 'ignores Bundler config files' do
          options[:ignore_config] = true
        end
      end

      def init_options(opts) # rubocop:disable Metrics/MethodLength
        opts.on '-i', '--init[=RUBY_DERIVATION]',
                "initialize a new flake.nix for 'nix develop' (won't overwrite old ones)" do |ruby|
          options[:init] = ruby || DEFAULTS[:ruby_derivation]
        end

        opts.on '-t', '--init-template=TEMPLATE',
                "the flake.nix template to use. may be #{template_list}, " \
                'or a filename (default: default)' do |template|
          options[:init_template] = parse_template(template)
        end

        opts.on '-p', '--init-project=NAME',
                "project name to use with --init #{default :project}" do |name|
          options[:project] = name
        end
      end

      def command_options(opts) # rubocop:disable Metrics/MethodLength
        opts.on '-v', '--version', 'show the version of bundix' do
          puts VERSION
          exit
        end

        opts.on '--env', 'show the environment in Bundix' do
          system('env')
          exit
        end

        opts.on '--platform', 'show the gem platform of this host' do
          puts LOCAL_PLATFORM
          exit
        end
      end

      def default(key)
        "(default: #{DEFAULTS[key]})"
      end

      def template_list
        FLAKE_NIX_TEMPLATES.keys.map { |str| "'#{str}'" }.join(', ')
      end
    end
  end
end
