# frozen_string_literal: true

require 'bundler'
require 'fileutils'
require 'json'
require 'net/http'
require 'open3'
require_relative 'bundix/converter'
require_relative 'bundix/dependency'
require_relative 'bundix/dependency_cache'
require_relative 'bundix/fetcher'
require_relative 'bundix/hash_with_nix_order'
require_relative 'bundix/http_fetcher'
require_relative 'bundix/nixer'
require_relative 'bundix/shell'
require_relative 'bundix/source'
require_relative 'bundix/version'

module Bundix
  NIX_INSTANTIATE = 'nix-instantiate'
  NIX_PREFETCH_URL = 'nix-prefetch-url'
  NIX_PREFETCH_GIT = 'nix-prefetch-git'
  NIX_HASH = 'nix-hash'
  NIX_SHELL = 'nix-shell'

  SHA256_32 = /^[a-z0-9]{52}$/.freeze

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
