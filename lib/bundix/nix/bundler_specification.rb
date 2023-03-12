# frozen_string_literal: true

module Bundix
  # {Serializer Serializes} a Bundler spec into nix format.
  class BundlerSpecification
    attr_reader :engines, :spec

    def initialize(spec, engines: RubyEngines.defaults)
      @spec = spec
      @engines = engines
    end

    def to_nix
      {
        dependencies: dependencies,
        groups: groups,
        source: Nix::BundlerSource.build(spec),
        version: version
      }.merge(engine)
    end

    private

    def version
      [spec.version, (platform unless ruby_platform?)].compact.join('-')
    end

    def platform
      @platform ||= spec.platform.to_s
    end

    def ruby_platform?
      platform == Gem::Platform::RUBY
    end

    def groups
      spec.groups.empty? ? %w[default] : spec.groups
    end

    def dependencies
      spec.dependencies.select(&:runtime?).map(&:name)
    end

    def engine
      eng = engines[spec.platform]
      eng == engines.default ? {} : { platforms: eng }
    end
  end
end
