# frozen_string_literal: true

module Bundix
  module Gemset
    # Convert a {Bundler::SpecSet} to a {Hash} of gem-platform/gemset pairs.
    class PlatformGems
      attr_reader :definition, :groups, :specs

      # @param definition [Bundler::Definition]
      # @param specs [#to_a] A list of Bundler specs.
      # @param groups [Array<#to_sym>] The list of Bundler groups to include.
      def initialize(definition, specs, groups: [:default])
        @definition = definition
        @specs = Bundler::SpecSet.new(specs.to_a)
        @groups = groups
      end

      def call
        Nix::Serializer.new(platform_gemsets).to_nix
      end

      private

      def platform_gemsets
        new_gemset_hash.tap do |gemsets|
          all_spec_dependencies.each { |spec| gemset_add(gemsets, spec) }
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
        @dependencies ||= definition.dependencies_for(groups)
      end

      def gem_platforms
        @gem_platforms ||=
          definition.platforms.map { |plat| Gem::Platform.new(plat) }
      end

      def gemset_add(gemsets, spec)
        prev = gemsets.dig(spec.platform.to_s, spec.name, spec.version)
        raise "version mismatch: #{prev}, #{spec}" if prev && prev.version != spec.version

        gemsets[spec.platform.to_s][spec.name] = Nix::BundlerSpecification.new(spec)
      end
    end
  end
end
