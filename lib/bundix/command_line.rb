# frozen_string_literal: true

require 'English'
require 'pathname'
require 'tmpdir'

module Bundix
  # Executes Bundix with the options given by the user via the command-line.
  class CommandLine
    attr_reader :options

    def self.call(...)
      new(...).call
    end

    # @param options [Hash] Options which affect the operation of the
    #   application. If none are given, {ARGV} will be parsed for command-line
    #   flags.
    # @see CommandLineOptions for available option keys.
    def initialize(**options)
      @options = options.empty? ? parse_options : options
    end

    def call
      handle_bundle_lock
      handle_bundle_cache
      handle_init
      save_gemset(build_gemset) unless options[:skip_gemset]
    end

    private

    def parse_options
      op = CommandLineOptions.new
      op.parse!

      $VERBOSE = !op.options[:quiet]
      op.options
    end

    def handle_bundle_lock
      bundle_lock if options[:lock] || options[:update_lock] || lockfile_stale?
    end

    def bundle_lock
      BundlerProxy::Lock
        .new(options[:gemfile], options[:lockfile], update: options[:update_lock])
        .call
    end

    def lockfile_stale?(lockfile: options[:lockfile], gemfile: options[:gemfile])
      !File.file?(lockfile) || File.mtime(gemfile) > File.mtime(lockfile)
    end

    def handle_bundle_cache
      return unless options[:cache]

      BundlerProxy::Cache.new(options[:cache], options[:gemfile]).call
    end

    def handle_init
      return unless options[:init]

      if File.file?('flake.nix')
        warn "won't override existing flake.nix but here is what it'd look like:"
        puts flake_nix_string
      else
        File.write('flake.nix', flake_nix_string)
      end
    end

    def flake_nix_string
      Nix::Template.new(options[:init_template])
                   .call(ruby: options[:init], **options)
    end

    def build_gemset
      Gemset::Builder
        .call(**options.slice(:gemfile, :lockfile, :bundler_env_format))
    end

    def fetcher
      Fetcher.new(bundler_settings: bundler_settings)
    end

    def bundler_settings
      @bundler_settings ||=
        BundlerSettings.new(bundler_root.join('.bundle'),
                            ignore_config: options[:ignore_config])
    end

    def bundler_root
      @bundler_root ||=
        %i[gemfile lockfile gemset].map { |key| Pathname(options[key]).dirname }
                                   .find(&:directory?)
    end

    def save_gemset(gemset)
      Nix::RubyToNix.new(options[:gemset]).call(gemset)
    end
  end
end
