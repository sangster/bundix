# frozen_string_literal: true

require 'optparse'

module Bundix
  # Parses commandline options.
  class CommandLineOptions < OptionParser
    FLAKE_NIX_TEMPLATES = {
      'default' => '../../template/flake.nix.erb',
      'flake-utils' => '../../template/flake-with-utils.nix.erb'
    }.transform_values { |path| Pathname(__dir__).join(path).freeze }.freeze

    DEFAULTS = {
      bundle_cache_path: './vendor/bundle',
      gemfile: './Gemfile',
      gemset: './gemset.nix',
      init_template: FLAKE_NIX_TEMPLATES['default'],
      lockfile: './Gemfile.lock',
      project: File.basename(Dir.pwd),
      ruby_derivation: 'ruby'
    }.freeze

    attr_accessor :options

    def initialize
      @options = DEFAULTS.dup
      super { |opts| make_options(opts) }
    end

    private

    def make_options(opts) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      opts.on '-i', '--init[=RUBY_DERIVATION]',
              "initialize a new flake.nix for 'nix develop' (won't overwrite old ones)" do |ruby|
        options[:init] = ruby || DEFAULTS[:ruby_derivation]
      end

      opts.on '-t', '--init-template=TEMPLATE',
              "the flake.nix template to use. may be #{template_list}, " \
              'or a filename (default: default)' do |template|
        options[:init_template] =
          if FLAKE_NIX_TEMPLATES.key?(template)
            FLAKE_NIX_TEMPLATES[template]
          elsif File.readable?(template)
            template
          else
            raise OptionParser::InvalidArgument, "--init-template=#{template}"
          end
      end

      opts.on '-p', '--init-project=NAME',
              "project name to use with --init #{default :project}" do |name|
        options[:project] = name
      end

      opts.on '--gemset=PATH', "path to the gemset.nix #{default :gemset}" do |value|
        options[:gemset] = File.expand_path(value)
      end

      opts.on '--lockfile=PATH', "path to the Gemfile.lock #{default :lockfile}" do |value|
        options[:lockfile] = File.expand_path(value)
      end

      opts.on '--gemfile=PATH', "path to the Gemfile #{default :gemfile}" do |value|
        options[:gemfile] = File.expand_path(value)
      end

      opts.on '-q', '--quiet', 'only output errors' do
        options[:quiet] = true
      end

      opts.on '-l', '--bundle-lock', 'generate Gemfile.lock first' do
        options[:lock] = true
      end

      opts.on '-u', '--bundle-update[=GEMS]',
              'ignores the existing lockfile. Resolve then updates lockfile. Taking a list of gems or updating ' \
              'all gems if no list is given (implies --bundle-lock)' do |gems|
        options[:update_lock] = gems || true
      end

      opts.on '-c', '--bundle-cache[=DIRECTORY]',
              "package .gem files into directory #{default :bundle_cache_path}" do |dir|
        options[:cache] = dir || DEFAULTS[:bundle_cache_path]
      end

      opts.on '-v', '--version', 'show the version of bundix' do
        puts VERSION
        exit
      end

      opts.on '--env', 'show the environment in bundix' do
        system('env')
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
