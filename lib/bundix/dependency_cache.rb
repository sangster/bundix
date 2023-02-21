# frozen_string_literal: true

module Bundix
  # Parses a Gemfile/Gemfile.lock pair and creates a map of dependency-names to
  # their {Bundler::Dependency}.
  class DependencyCache
    attr_reader :gemfile, :lockfile

    def initialize(lockfile, gemfile)
      @lockfile = lockfile
      @gemfile = gemfile
    end

    def fetch(key)
      dep_cache.fetch(key)
    end

    def lockfile_parser
      @lockfile_parser ||= Bundler::LockfileParser.new(File.read(lockfile))
    end

    private

    def dep_cache
      @dep_cache ||= build_depcache
    end

    def build_depcache
      new_cache = {}
      add_top_level_gems_and_specs(new_cache)

      loop do
        changed = false
        lockfile_parser.specs.each do |spec|
          changed = add_spec_set(new_cache, spec) || changed
        end
        break unless changed
      end

      new_cache
    end

    def bundler_definition
      @bundler_definition ||= Bundler::Definition.build(gemfile, lockfile, false)
    end

    def add_top_level_gems_and_specs(new_cache)
      bundler_definition.dependencies.each { |dep| new_cache[dep.name] = dep }

      lockfile_parser.specs.each do |spec|
        new_cache[spec.name] ||= Dependency.new(spec.name, nil, {})
      end
    end

    # @param new_cache [Hash]
    # @param spec_set [Bundler::SpecSet]
    # @return [Boolean] TODO If something has changed?
    def add_spec_set(new_cache, spec_set)
      changed = false
      spec_dep = new_cache.fetch(spec_set.name)

      spec_set.dependencies.each do |dep|
        changed = add_spec_set_dependency(new_cache, spec_dep, dep.name) || changed
      end

      changed
    end

    # @param new_cache [Hash]
    # @param spec_dep [Bundler::Dependency]
    # @param dep_name [String]
    # @return [Boolean] TODO If something has changed?
    def add_spec_set_dependency(new_cache, spec_dep, dep_name)
      dep = new_cache.fetch(dep_name) do |name|
        assert_bundler_dep!(name)
        bundler_dependency
      end
      return false unless groups_or_platforms_diff?(spec_dep, dep)

      new_cache[dep.name] = build_dependency(spec_dep, dep)
      true
    end

    def assert_bundler_dep!(name)
      return if name == 'bundler'

      raise KeyError, "Gem dependency '#{name}' not specified in #{lockfile}"
    end

    def bundler_dependency
      @bundler_dependency ||= Dependency.new('bundler', lockfile_parser.bundler_version, {})
    end

    def groups_or_platforms_diff?(as_dep, cached)
      !((as_dep.groups - cached.groups) - [:default]).empty? ||
        !(as_dep.platforms - cached.platforms).empty?
    end

    def build_dependency(spec_dep, dep)
      Dependency.new(
        dep.name,
        nil,
        {
          'group' => spec_dep.groups | dep.groups,
          'platforms' => spec_dep.platforms | dep.platforms
        }
      )
    end
  end
end
