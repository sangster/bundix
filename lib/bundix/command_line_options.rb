# frozen_string_literal: true

module Bundix
  # Parses commandline options.
  class CommandLineOptions < OptionParser
    DEFAULT_OPTIONS = {
      ruby: 'ruby',
      bundle_pack_path: 'vendor/bundle',
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
      opts.on '-m', '--magic', 'lock, pack, and write dependencies' do
        options[:magic] = true
      end

      opts.on "--ruby=#{options[:ruby]}", 'ruby version to use for magic and init, defaults to latest' do |value|
        options[:ruby] = value
      end

      opts.on "--bundle-pack-path=#{options[:bundle_pack_path]}", 'path to pack the magic' do |value|
        options[:bundle_pack_path] = value
      end

      opts.on '-i', '--init', "initialize a new shell.nix for nix-shell (won't overwrite old ones)" do
        options[:init] = true
      end

      opts.on '-q', '--quiet', 'only output errors' do
        options[:quiet] = true
      end

      opts.on '-l', '--lock', 'generate Gemfile.lock first' do
        options[:lock] = true
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
