# frozen_string_literal: true

module Bundix
  # Maps ruby versions to the engines they support.
  class Platforms
    PLATFORM_ENGINES = {
      'ruby' => [{ engine: 'ruby' }, { engine: 'rbx' }, { engine: 'maglev' }],
      'mri' => [{ engine: 'ruby' }, { engine: 'maglev' }],
      'rbx' => [{ engine: 'rbx' }],
      'jruby' => [{ engine: 'jruby' }],
      'mswin' => [{ engine: 'mswin' }],
      'mswin64' => [{ engine: 'mswin64' }],
      'mingw' => [{ engine: 'mingw' }],
      'truffleruby' => [{ engine: 'ruby' }],
      'x64_mingw' => [{ engine: 'mingw' }]
    }.freeze
    SUPPORTED_RUBY_VERSIONS = %w[1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7].freeze

    PLATFORM_VERSION_ENGINES = PLATFORM_ENGINES.flat_map do |name, list|
      SUPPORTED_RUBY_VERSIONS.map do |version|
        [
          "#{name}_#{version.sub(/[.]/, '')}",
          list.map { |platform| platform.merge(version: version) }
        ]
      end
    end.to_h.freeze

    attr_reader :supported

    def self.defaults
      new(PLATFORM_ENGINES.merge(PLATFORM_VERSION_ENGINES))
    end

    def initialize(supported)
      @supported = supported
    end

    def [](key)
      supported.fetch(key.to_s)
    end
  end
end
