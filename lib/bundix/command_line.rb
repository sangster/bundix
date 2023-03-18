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
    # @see CommandLine::Options for available option keys.
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
      op = CommandLine::Options.new
      op.parse!

      $VERBOSE = !op.options[:quiet]
      op.options
    end

    def handle_bundle_lock
      bundle_lock if lock_option? || lockfile_stale?
    end

    def bundle_lock
      BundlerProxy::Lock
        .new(definition, **options.slice(*%i[add_platforms remove_platforms
                                             set_platforms update]))
        .call
    end

    def definition
      Bundler::Definition.build(options[:gemfile], options[:lockfile], false)
    end

    def lock_option?
      %i[add_platforms lock remove_platforms set_platforms update]
        .any? { options[_1] }
    end

    def lockfile_stale?(lockfile: options[:lockfile], gemfile: options[:gemfile])
      !File.file?(lockfile) || File.mtime(gemfile) > File.mtime(lockfile)
    end

    def handle_bundle_cache
      return unless options[:cache]

      BundlerProxy::Cache.new(**options.slice(:cache, :gemfile)).call
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
                   .call(ruby: options[:init], gemdir: gemdir, **options)
    end

    def gemdir
      return @gemdir if defined? @gemdir

      @gemdir = begin
        paths = options.slice(:gemfile, :lockfile, :gemset).values.map { Pathname(_1) }
        return nil unless paths.map { _1.basename.to_s } == %w[Gemfile Gemfile.lock gemset.nix]

        dirs = paths.map(&:dirname).uniq
        dirs.size == 1 ? dirs.first : nil
      end
    end

    def build_gemset
      Gemset::Builder
        .call(definition, **options.slice(*%i[groups bundler_env_format]))
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
