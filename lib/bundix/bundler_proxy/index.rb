# frozen_string_literal: true

module Bundix
  module BundlerProxy
    # A service class to generate an index of all gems that may be necessary to
    # fulfill the dependencies of a lockfile.
    #
    # Some gems, especially those with native extensions, may provide different
    # versions for different platforms or require different sub-dependencies.
    class Index
      attr_reader :engines, :lockfile_parser

      def self.build(lockfile, engines: RubyEngines.defaults)
        new(Bundler::LockfileParser.new(File.read(lockfile)),
            engines: engines)
      end

      def initialize(lockfile_parser, engines: Platforms.defaults)
        @lockfile_parser = lockfile_parser
        @engines = engines
      end

      # @return [Hash<String, Hash>] A Hash describing gems available to
      #   different platforms. The +"dependencies"+ entry is an array of gem
      #   names defined as dependencies of the lockfile. The 'platforms' entry
      #   contains a map of engines to the gems available to that platform.
      def call
        sources_map.each_key { |source| add_specs_from_source(source) }
        { 'dependencies' => dependencies, 'platforms' => platform_map }
      end

      private

      def dependencies
        @lockfile_parser.dependencies.keys
      end

      def add_specs_from_source(source)
        source_specs(source).each { |spec| add_to_platform(spec) }
      end

      def source_specs(source)
        case source
        when Bundler::Source::Git then CloneGit.new(source).call.specs
        when Bundler::Source::Path then source.specs
        when Bundler::Source::Rubygems then gem_specs(source)
        else
          raise "unexpected source: #{source}"
        end
      end

      def gem_specs(source)
        cached_rubygem_specs[source]
          .select { |spec| spec.version == lockfile_versions[spec.name] }
      end

      # Download RubyGems index
      def cached_rubygem_specs
        @cached_rubygem_specs ||= Hash.new do |hash, source|
          names = sources_map.fetch(source, []).map(&:name)

          hash[source] = source.fetchers
                               .first # TODO: use all fetchers? or "api fetcher?"
                               .specs_with_retry(names, source)
        end
      end

      def lockfile_versions
        @lockfile_versions ||= lockfile_parser.specs.to_h do |spec|
          [spec.name, spec.version]
        end
      end

      def add_to_platform(spec)
        platform_map[spec.platform.to_s][spec.name] =
          Nix::BundlerSpecification.new(spec, engines: engines)
      end

      # Nested hash: platform -> spec name -> spec details
      def platform_map
        @platform_map ||= Hash.new do |pmap, platform|
          pmap[platform] = Hash.new do |smap, spec_name|
            smap[spec_name] = {}
          end
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
