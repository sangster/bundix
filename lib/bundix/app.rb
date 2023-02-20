# frozen_string_literal: true

module Bundix
  class App
    attr_reader :options
    attr_accessor :fetcher

    def self.sh(*args, &block)
      out, status = Open3.capture2(*args)
      unless block_given? ? block.call(status, out) : status.success?
        puts "$ #{args.join(' ')}" if $VERBOSE
        puts out if $VERBOSE
        raise "command execution failed: #{status}"
      end
      out
    end

    def initialize(options)
      @options = { quiet: false, tempfile: nil }.merge(options)
      @fetcher = Fetcher.new
    end

    def convert
      cache = parse_gemset
      lock = parse_lockfile
      dep_cache = build_depcache(lock)

      # reverse so git comes last
      lock.specs.reverse_each.with_object({}) do |spec, gems|
        gem = find_cached_spec(spec, cache) || convert_spec(spec, cache, dep_cache)
        gems.merge!(gem)

        gems[spec.name]['dependencies'] = spec.dependencies.map(&:name) - ['bundler'] if spec.dependencies.any?
      end
    end

    def groups(spec, dep_cache)
      { groups: dep_cache.fetch(spec.name).groups }
    end

    def platforms(spec, dep_cache)
      # c.f. Bundler::CurrentRuby
      platforms = dep_cache.fetch(spec.name).platforms.map do |platform_name|
        PLATFORM_MAPPING[platform_name.to_s]
      end.flatten

      { platforms: platforms }
    end

    def convert_spec(spec, _cache, dep_cache)
      {
        spec.name => {
          version: spec.version.to_s,
          source: Source.new(spec, fetcher).convert
        }.merge(platforms(spec, dep_cache)).merge(groups(spec, dep_cache))
      }
    rescue StandardError => e
      warn "Skipping #{spec.name}: #{e}"
      puts e.backtrace
      { spec.name => {} }
    end

    def find_cached_spec(spec, cache)
      name, cached = cache.find do |k, v|
        next unless k == spec.name
        next unless (cached_source = v['source'])

        case spec_source = spec.source
        when Bundler::Source::Git
          next unless cached_source['type'] == 'git'
          next unless (cached_rev = cached_source['rev'])
          next unless (spec_rev = spec_source.options['revision'])

          spec_rev == cached_rev
        when Bundler::Source::Rubygems
          next unless cached_source['type'] == 'gem'

          v['version'] == spec.version.to_s
        end
      end

      { name => cached } if cached
    end

    def build_depcache(lock)
      definition = Bundler::Definition.build(options[:gemfile], options[:lockfile], false)
      dep_cache = {}

      definition.dependencies.each do |dep|
        dep_cache[dep.name] = dep
      end

      lock.specs.each do |spec|
        dep_cache[spec.name] ||= Dependency.new(spec.name, nil, {})
      end

      loop do
        changed = false
        lock.specs.each do |spec|
          as_dep = dep_cache.fetch(spec.name)

          spec.dependencies.each do |dep|
            cached = dep_cache.fetch(dep.name) do |name|
              raise KeyError, "Gem dependency '#{name}' not specified in #{lockfile}" if name != 'bundler'

              dep_cache[name] = Dependency.new(name, lock.bundler_version, {})
            end

            unless !((as_dep.groups - cached.groups) - [:default]).empty? || !(as_dep.platforms - cached.platforms).empty?
              next
            end

            changed = true
            dep_cache[cached.name] =
              Dependency.new(cached.name, nil, {
                               'group' => as_dep.groups | cached.groups,
                               'platforms' => as_dep.platforms | cached.platforms
                             })

            dep_cache[cached.name]
          end
        end
        break unless changed
      end

      dep_cache
    end

    def parse_gemset
      path = File.expand_path(options[:gemset])
      return {} unless File.file?(path)

      json = self.class.sh(NIX_INSTANTIATE, '--eval', '-E', %(
      builtins.toJSON (import #{Nixer.serialize(path)})))
      JSON.parse(json.strip.gsub(/\\"/, '"')[1..-2])
    end

    def parse_lockfile
      Bundler::LockfileParser.new(File.read(options[:lockfile]))
    end
  end
end
