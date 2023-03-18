# frozen_string_literal: true

require 'bundler'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Bundix
  CACHE_DIR = Pathname(ENV['XDG_CACHE_HOME'] || "#{Dir.home}/.cache").join('bundix').freeze
  SHA256_32 = /^[a-z0-9]{52}$/.freeze
  TEMPLATES = Pathname(__dir__).join('../templates').freeze

  FLAKE_NIX_TEMPLATES = {
    'default' => TEMPLATES.join('flake-nix/default.nix.erb'),
    'flake-utils' => TEMPLATES.join('flake-nix/flake-utils.nix.erb')
  }.freeze

  # @see {CommandLine::Options}
  DEFAULT_OPTIONS = {
    bundle_cache_path: './vendor/bundle',
    gemfile: './Gemfile',
    gemset: './gemset.nix',
    ignore_config: false,
    init_template: FLAKE_NIX_TEMPLATES['default'],
    lockfile: './Gemfile.lock',
    project: File.basename(Dir.pwd).freeze,
    ruby_derivation: 'ruby',
    ruby_platform: 'ruby',
    skip_gemset: false
  }.freeze

  LOCAL_PLATFORM = Gem::Platform.local.to_s.freeze

  Error = Class.new(RuntimeError)
  BundlerError = Class.new(Error)
  ProcessError = Class.new(Error)
end

loader.eager_load
