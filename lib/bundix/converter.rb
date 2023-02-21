# frozen_string_literal: true

module Bundix
  # A service to parse a Gemfile/Gemfile.lock pair, download any gem
  # dependencies, and calculate their hashes.
  class Converter
    attr_reader :options
    attr_accessor :fetcher

    def initialize(options)
      @options = { quiet: false, tempfile: nil }.merge(options)
      @fetcher = Fetcher.new
    end

    def convert
      # reverse so git comes last
      lockfile.specs.reverse_each.with_object({}) do |spec, gems|
        convert_spec!(spec, gems)
      end
    end

    def parse_gemset
      path = File.expand_path(options[:gemset])
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

    def platforms(spec)
      # c.f. Bundler::CurrentRuby
      platforms = dependency_cache.fetch(spec.name).platforms.map do |platform_name|
        PLATFORM_MAPPING[platform_name.to_s]
      end.flatten

      { platforms: platforms }
    end

    def convert_single_spec(spec)
      {
        spec.name => {
          version: spec.version.to_s,
          source: Source.new(spec, fetcher).convert
        }.merge(platforms(spec)).merge(groups(spec))
      }
    rescue StandardError => e
      warn "Skipping #{spec.name}: #{e}"
      puts e.backtrace
      { spec.name => {} }
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

    def cached_rubygems_spec?(cached_source, version, spec)
      cached_source['type'] == 'gem' && version == spec.version.to_s
    end
  end
end
