# frozen_string_literal: true

module Bundix
  module Gemset
    # This {Builder} renders the contents of a +gemset.nix+ that is suiltable
    # for the +builderEnv+ nix function.
    class EnvFormatBuilder < Builder
      attr_reader :platform

      # @param platform [String] The platform of the gems to include.
      # @param kwargs [Hash] See {Builder#new}.
      def initialize(platform, **kwargs)
        super(**kwargs)
        @platform = platform
      end

      def call
        @gemset = super
        compile({}, @gemset[:dependencies])
      end

      private

      def compile(newset, deps)
        return newset if deps.empty?

        name = deps.first
        spec = platform_specs[name] || ruby_specs[name]
        raise "no suitable '#{name}' gem for '#{platform}' platform" unless spec

        newset[name] = spec
        compile(newset, deps[1..] + Array(spec[:dependencies]))
      end

      def platform_specs
        @platform_specs ||= @gemset[:platforms].fetch(platform, {})
      end

      def ruby_specs
        @ruby_specs ||= @gemset[:platforms].fetch('ruby', {})
      end
    end
  end
end
