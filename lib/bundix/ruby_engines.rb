# frozen_string_literal: true

module Bundix
  # The nix function +bundlerEnv+ checks that each gem can be executed by the
  # ruby interpreter being used. This is significant for gems that provide
  # native extensions.
  #
  # +bundlerEnv+ expects the ruby interpreter's nix deriviation to export two
  # attrs: +rubyEngine+ and +version+ to compare against.
  #
  # @see https://github.com/NixOS/nixpkgs/blob/48e4e2a1/pkgs/development/ruby-modules/bundled-common/functions.nix#L44-L51
  # @see https://guides.rubygems.org/gems-with-extensions/
  class RubyEngines
    DEFAULT = [{ engine: 'ruby' }].freeze

    # TODO: Aside from jruby, how many of these are still in Euse?
    # TODO: Are these the correct strings used gem platforms?
    # @see +gem help platforms+
    PLATFORM_ENGINES = {
      Gem::Platform::RUBY => DEFAULT + [{ engine: 'rbx' }, { engine: 'maglev' }],
      'mri' => DEFAULT + [{ engine: 'maglev' }],
      'rbx' => [{ engine: 'rbx' }],
      'java' => [{ engine: 'jruby' }],
      'jruby' => [{ engine: 'jruby' }],
      'mswin' => [{ engine: 'mswin' }],
      'mswin64' => [{ engine: 'mswin64' }],
      'mingw' => [{ engine: 'mingw' }],
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

    DEFAULT_SUPPORTED = PLATFORM_ENGINES.merge(PLATFORM_VERSION_ENGINES)

    attr_reader :supported

    def self.defaults
      @defaults ||= new(DEFAULT_SUPPORTED)
    end

    # @param supported [Hash<String, Array<Hash<Symbol,String>>>]
    def initialize(supported)
      @supported = supported
    end

    # @param key [String]
    # @return [Array<Hash<Symbol, String>>]
    def [](key)
      supported.fetch(key.to_s, default)
    end

    # @return [Array<Hash<Symbol, String>>] The default platform for gems that
    #   don't specify one.
    def default
      DEFAULT
    end

    def inspect
      return super unless supported.equal?(DEFAULT_SUPPORTED)

      "#<#{self.class.name}:#{object_id} defaults>"
    end
  end
end
