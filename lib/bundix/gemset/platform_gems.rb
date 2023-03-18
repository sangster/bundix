# frozen_string_literal: true

module Bundix
  module Gemset
    # Convert a {Bundler::SpecSet} to a {Hash} of gem-platform/gemset pairs.
    class PlatformGems
      attr_reader :definition, :groups, :specs

      # @param definition [Bundler::Definition]
      # @param specs [#to_a] A list of Bundler specs.
      # @param groups [nil,Array<#to_sym>] The list of Bundler groups to
      #   include, or +nil+ for all.
      def initialize(definition, specs, groups: nil)
        @definition = definition
        @specs = Bundler::SpecSet.new(specs.to_a)
        @groups = groups || definition.groups
      end

      def call
        Nix::Serializer.new(platform_gemsets).to_nix
      end

      private

      def platform_gemsets
        new_gemset_hash.tap do |gemsets|
          all_spec_dependencies.each do |spec|
            gemset_add(gemsets, spec, group_specs[spec_id(spec)])
          end
        end
      end

      # Nested hash: platform -> spec name -> spec details
      def new_gemset_hash
        Hash.new do |pmap, platform|
          pmap[platform] = Hash.new { |smap, name| smap[name] = {} }
        end
      end

      def all_spec_dependencies
        Set.new.tap do |set|
          gem_platforms.each { |platform| set.merge(platform_gemset(platform)) }
        end
      end

      def platform_gemset(platform)
        specs.for(dependencies, false, [platform])
      end

      def dependencies
        groups.flat_map { group_dependencies[_1] }
      end

      def all_dependencies
        @all_dependencies ||=
          [
            dependencies,
            definition.resolve.flat_map(&:dependencies)
          ].flatten.sort.uniq
      end

      def group_dependencies
        @group_dependencies ||= groups.to_h do |group|
          [group.to_sym, definition.dependencies_for([group.to_sym])]
        end
      end

      def gem_platforms
        @gem_platforms ||=
          definition.platforms.map { |plat| Gem::Platform.new(plat) }
      end

      def gemset_add(gemsets, spec, groups)
        prev = gemsets.dig(spec.platform.to_s, spec.name, spec.version)
        raise "version mismatch: #{prev}, #{spec}" if prev && prev.version != spec.version

        gemsets[spec.platform.to_s][spec.name] =
          Nix::BundlerSpecification.new(spec, groups: groups)
      end

      def group_specs
        @group_specs ||=
          Hash.new { |h1, spec| h1[spec] = [] }
              .tap { |hash| add_dependencies_to_groups(hash, dependencies) }
      end

      def add_spec_to_groups(hash, spec, groups)
        hash[spec_id(spec)] = groups
        add_dependencies_to_groups(hash, spec.dependencies, groups: groups)
      end

      def add_dependencies_to_groups(hash, deps, groups: nil)
        deps.each do |dep|
          next if dep.name == 'bundler'

          spec = definition.resolve.find { dep.matches_spec?(_1) }
          raise "No spec for #{dep}" unless spec

          add_spec_to_groups(hash, spec, groups || dep.groups)
        end
      end

      def spec_id(spec)
        [spec.name, spec.version, spec.platform]
      end
    end
  end
end
