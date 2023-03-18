# frozen_string_literal: true

module Bundix
  module Gemset
    # A service class to generate the contents of +gemfile.nix+, describing the
    # rubygem derivations required by the +Gemfile+ on different platforms.
    #
    # Some gems, especially those with native extensions, may provide different
    # versions for different platforms, and those versions may vary in their own
    # transitive dependencies.
    class Builder
      # Download RubyGems index, with SHA-256 hashes
      class RubyGemsApi
        def initialize(source)
          @source = source
        end

        def call(names)
          @source.fetchers
                 .first # TODO: use all fetchers? or "api fetcher?"
                 .specs_with_retry(names, @source)
        end
      end

      attr_reader :definition, :engines, :groups

      class << self
        def call(...)
          build(...).call
        end

        def build(*args, bundler_env_format: nil, **kwargs)
          if bundler_env_format
            EnvFormatBuilder.new(bundler_env_format, *args, **kwargs)
          else
            new(*args, **kwargs)
          end
        end
      end

      # @param groups [nil, Array<#to_sym>] The Bundler groups to include, or
      #   +nil+ for all.
      # @param engines [RubyEngines]
      # @see https://bundler.io/guides/groups.html
      def initialize(definition, groups: nil, engines: RubyEngines.defaults)
        @definition = definition
        @groups = compact_groups(groups)
        @engines = engines
      end

      # @return [Hash<String, Hash>] A Hash describing gems available to
      #   different platforms. The +:dependencies+ entry is an array of gem
      #   names defined as dependencies of the lockfile. The +:platforms+ entry
      #   contains a map of gem-platforms to the gems available to that
      #   platform.
      def call
        { dependencies: dependencies, platforms: platforms }
      end

      def dependencies
        @dependencies ||= definition.dependencies_for(groups).map(&:name)
      end

      def platforms
        @platforms ||=
          PlatformGems.new(definition, all_lockfile_specs, groups: groups).call
      end

      def lockfile_parser
        definition.locked_gems
      end

      private

      def compact_groups(groups)
        groups ||= definition.groups
        (groups.map(&:to_sym) + [:default]).uniq
      end

      def all_lockfile_specs
        specs = lockfile_sources.flat_map { |source| source_specs(source).to_a }
        deps = sources_map.values.flatten
        specs.select do |spec|
          deps.find do |dep|
            %i[name version platform].all? do |attr|
              spec.send(attr) == dep.send(attr)
            end
          end
        end
      end

      def source_specs(source)
        case source
        when Bundler::Source::Git then git_specs(source)
        when Bundler::Source::Path then source.specs
        when Bundler::Source::Rubygems then cached_rubygem_specs[source]
        else
          raise "unexpected source: #{source}"
        end
      end

      def git_specs(source)
        BundlerProxy::CloneGit.new(source).call.specs
      end

      def cached_rubygem_specs
        @cached_rubygem_specs ||= Hash.new do |hash, source|
          hash[source] =
            RubyGemsApi.new(source)
                       .call(sources_map.fetch(source, []).map(&:name))
        end
      end

      def sources_map
        @sources_map ||= lockfile_sources.to_h { |s| [s, lockfile_specs(s)] }
      end

      def lockfile_sources
        lockfile_parser.specs.map(&:source).uniq
      end

      def lockfile_specs(source)
        lockfile_parser.specs.select { |spec| spec.source == source }
      end
    end
  end
end
