# frozen_string_literal: true

require 'bundler/cli'
require 'bundler/cli/lock'

module Bundix
  module BundlerProxy
    # Executes +bundle lock+ or +bundle lock --update+.
    class Lock < Base
      attr_reader :definition, :ignore_config, :set_platforms, :update

      def initialize(definition, update: false, ignore_config: false, # rubocop:disable Metrics/ParameterLists
                     add_platforms: [], remove_platforms: [], set_platforms: nil,
                     **kwargs)
        super(**kwargs)
        @definition = definition
        @update = update
        @ignore_config = ignore_config
        @add_platforms = add_platforms
        @remove_platforms = remove_platforms
        @set_platforms = set_platforms || current_platforms
      end

      def add_platforms
        @add_platforms + (set_platforms - current_platforms)
      end

      def remove_platforms
        @remove_platforms + (current_platforms - set_platforms)
      end

      protected

      def bundler_process
        cli.run
      end

      def env
        {
          'BUNDLE_FROZEN' => nil,
          'BUNDLE_PATH' => cache_dir,
          'BUNDLE_GEMFILE' => gemfile,
          'BUNDLE_IGNORE_CONFIG' => (ignore_config ? 'true' : nil)
        }
      end

      private

      def cli
        Bundler::CLI::Lock
          .new('remove-platform' => remove_platforms,
               'add-platform' => add_platforms,
               lockfile: definition.lockfile,
               gemfile: gemfile,
               update: update)
      end

      def current_platforms
        @current_platforms ||= definition.platforms.map(&:to_s)
      end

      def gemfile
        definition.gemfiles.first
      end
    end
  end
end
