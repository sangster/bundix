# frozen_string_literal: true

module Bundix
  module Nix
    # {Serializer Serializes} a Bundler spec into nix format.
    class BundlerSpecification
      attr_reader :engines, :groups, :spec

      def initialize(spec, groups: nil, engines: RubyEngines.defaults)
        @spec = spec
        @groups = compact_groups(groups)
        @engines = engines
      end

      def to_nix
        {
          dependencies: dependencies,
          groups: groups,
          source: Nix::BundlerSource.build(spec),
          version: version,
          platforms: engine
        }.compact
      end

      def dependencies
        spec.dependencies
            .select(&:runtime?)
            .map(&:name)
            .tap { _1.delete('bundler') }
            .then { _1.empty? ? nil : _1 }
      end

      private

      def compact_groups(groups)
        groups = Array(groups).map(&:to_sym)
        return nil if (groups - [:default]).empty?

        groups
      end

      def version
        [spec.version, (platform unless ruby_platform?)].compact.join('-')
      end

      def platform
        @platform ||= spec.platform.to_s
      end

      def ruby_platform?
        platform == Gem::Platform::RUBY
      end

      def engine
        engines[spec.platform] unless spec.platform == Gem::Platform::RUBY
      end
    end
  end
end
