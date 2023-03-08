# frozen_string_literal: true

require 'English'
require 'pathname'
require 'tmpdir'

module Bundix
  # Provides a command-line interface to {Converter}.
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
      save_gemset(build_gemset)
    end

    private

    def parse_options
      op = CommandLineOptions.new
      op.parse!

      $VERBOSE = !op.options[:quiet]
      op.options
    end

    def handle_bundle_lock
      bundle_lock if (options[:lock] && lockfile_stale?) || options[:update_lock]
    end

    def bundle_lock
      BundlerProxy::Lock
        .new(options[:gemfile], options[:lockfile], update: options[:update_lock])
        .call
        .tap { |result| raise unless result }
    end

    def lockfile_stale?(lockfile: options[:lockfile], gemfile: options[:gemfile])
      !File.file?(lockfile) || File.mtime(gemfile) > File.mtime(lockfile)
    end

    def handle_bundle_cache
      return unless options[:cache]

      BundlerProxy::Cache.new(options[:cache], options[:gemfile])
                         .call
                         .tap { |result| raise unless result }
    end

    def handle_init
      return unless options[:init]

      if File.file?('shell.nix')
        warn "won't override existing shell.nix but here is what it'd look like:"
        puts shell_nix_string
      else
        File.write('shell.nix', shell_nix_string)
      end
    end

    def shell_nix_string
      Nix::Template.new(SHELL_NIX_TEMPLATE)
                   .call(ruby: options[:init], **options)
    end

    def build_gemset
      Converter.call(fetcher: fetcher, **options)
    end

    def fetcher
      Fetcher.new(bundler_settings: bundler_settings)
    end

    def bundler_settings
      @bundler_settings ||=
        BundlerProxy::Settings.new(bundler_root.join('.bundle'),
                                   ignore_config: false) # TODO: get from CLI options
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
