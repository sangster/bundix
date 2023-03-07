# frozen_string_literal: true

require 'optparse'

module Bundix
  # Parses commandline options.
  class CommandLineOptions < OptionParser
    DEFAULT_OPTIONS = {
      ruby: 'ruby',
      bundle_cache_path: 'vendor/bundle',
      gemfile: 'Gemfile',
      lockfile: 'Gemfile.lock',
      gemset: 'gemset.nix',
      project: File.basename(Dir.pwd)
    }.freeze

    attr_accessor :options

    def initialize
      @options = DEFAULT_OPTIONS.dup
      super { |opts| make_options(opts) }
    end

    private

    def make_options(opts) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      opts.on "--ruby=#{options[:ruby]}",
              'ruby version to use for magic and init, defaults to latest' do |value|
        options[:ruby] = value
      end

      opts.on '-i', '--init', "initialize a new shell.nix for nix-shell (won't overwrite old ones)" do
        options[:init] = true
      end

      opts.on "--gemset=#{options[:gemset]}", 'path to the gemset.nix' do |value|
        options[:gemset] = File.expand_path(value)
      end

      opts.on "--lockfile=#{options[:lockfile]}", 'path to the Gemfile.lock' do |value|
        options[:lockfile] = File.expand_path(value)
      end

      opts.on "--gemfile=#{options[:gemfile]}", 'path to the Gemfile' do |value|
        options[:gemfile] = File.expand_path(value)
      end

      opts.on '-q', '--quiet', 'only output errors' do
        options[:quiet] = true
      end

      opts.on '-l', '--bundle-lock', 'generate Gemfile.lock first' do
        options[:lock] = true
      end

      opts.on '-u', '--bundle-update [gems]',
              'Ignores the existing lockfile. Resolve then updates lockfile. Taking a list of gems or updating ' \
              'all gems if no list is given (implies --bundle-lock)' do |gems|
        options[:update_lock] = gems || true
      end

      opts.on '-c', '--bundle-cache', 'Package your needed .gem files into your application' do
        options[:cache] = true
      end

      opts.on "--bundle-cache-path=#{options[:bundle_cache_path]}", 'Path to pack built gems' do |value|
        options[:bundle_cache_path] = value
      end

      opts.on '-v', '--version', 'show the version of bundix' do
        puts VERSION
        exit
      end

      opts.on '--env', 'show the environment in bundix' do
        system('env')
        exit
      end
    end
  end
end
