# frozen_string_literal: true

require 'json'

module Bundix
  # A service to parse a Gemfile/Gemfile.lock pair, download any gem
  # dependencies, and calculate their hashes.
  class Converter
    DEFAULT_OPTIONS = { quiet: false, tempfile: nil }.freeze

    attr_reader :fetcher, :options, :platforms

    def self.call(...)
      new(...).call
    end

    # @params fetcher [Fetcher]
    # @params platforms [Platforms]
    # @params options [Hash]
    def initialize(fetcher: Fetcher.new, platforms: Platforms.defaults,
                   **options)
      @fetcher = fetcher
      @platforms = platforms
      @options = DEFAULT_OPTIONS.merge(**options)
    end

    def call
      # reverse so git comes last
      lockfile.specs.reverse_each.with_object({}) do |spec, gems|
        convert_spec!(spec, gems)
      end
    end

    def parse_gemset
      path = File.expand_path(options[:gemset].to_s)
      File.file?(path) ? JSON.parse(System.nix_to_json(path)) : {}
    end

    private

    def convert_spec!(spec, gems)
      gem = find_cached_spec(spec, cache) || convert_single_spec(spec)
      gems.merge!(gem)

      gems[spec.name]['dependencies'] = spec.dependencies.map(&:name) - ['bundler'] if spec.dependencies.any?
    end

    def dependency_cache
      @dependency_cache ||= DependencyCache.new(options[:lockfile], options[:gemfile])
    end

    def lockfile
      dependency_cache.lockfile_parser
    end

    def cache
      @cache ||= parse_gemset
    end

    def groups(spec)
      { groups: dependency_cache.fetch(spec.name).groups }
    end

    def convert_single_spec(spec)
      value = { version: spec.version.to_s, source: spec_source(spec) }
      { spec.name => value.merge(platforms: spec_platforms(spec)).merge(groups(spec)) }
    rescue Bundler::Dsl::DSLError
      raise
    rescue StandardError => e
      warn "Skipping #{spec.name}: #{e}"
      puts e.backtrace
      { spec.name => {} }
    end

    def spec_source(spec)
      Source.new(spec, fetcher).convert
    end

    def spec_platforms(spec)
      # c.f. Bundler::CurrentRuby
      dependency_cache
        .fetch(spec.name)
        .platforms
        .map { |platform_name| platforms[platform_name] }
        .flatten
    end

    def find_cached_spec(spec, cache)
      name, cached = cache.find { |k, v| spec_matches?(spec, k, v) }

      { name => cached } if cached
    end

    def spec_matches?(spec, key, value)
      cached_source = value['source']
      return false unless key == spec.name && cached_source

      case spec.source
      when Bundler::Source::Git
        cached_git_spec?(cached_source, spec.source)
      when Bundler::Source::Rubygems
        cached_rubygems_spec?(cached_source, value['version'], spec.version.to_s)
      end
    end

    def cached_git_spec?(cached_source, spec_source)
      cached_rev = cached_source['rev']
      spec_rev = spec_source.options['revision']

      cached_source['type'] == 'git' &&
        cached_rev &&
        spec_rev &&
        spec_rev == cached_rev
    end

    def cached_rubygems_spec?(cached_source, version, spec_version)
      cached_source['type'] == 'gem' && version == spec_version
    end
  end
end
