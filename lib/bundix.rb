# frozen_string_literal: true

require 'bundler'
require 'fileutils'
require 'json'
require 'net/http'
require 'open3'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

module Bundix
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

  PLATFORM_MAPPING = PLATFORM_ENGINES.merge(PLATFORM_VERSION_ENGINES).freeze
end
