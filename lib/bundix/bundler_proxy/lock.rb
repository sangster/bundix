# frozen_string_literal: true

require 'bundler/cli'
require 'bundler/cli/lock'

module Bundix
  module BundlerProxy
    # Executes +bundle lock+ or +bundle lock --update+.
    class Lock < Base
      attr_reader :gemfile, :lockfile, :update
      attr_accessor :add_platforms, :remove_platforms

      def initialize(gemfile, lockfile, update: false, **kwargs)
        super(**kwargs)
        @gemfile = gemfile
        @lockfile = lockfile
        @update = update
        @add_platforms = []
        @remove_platforms = []
      end

      protected

      def cli
        Bundler::CLI::Lock
          .new('remove-platform' => remove_platforms,
               'add-platform' => add_platforms,
               lockfile: lockfile,
               gemfile: gemfile,
               update: update)
      end

      def env
        {
          'BUNDLE_FROZEN' => nil,
          'BUNDLE_PATH' => cache_dir,
          'BUNDLE_GEMFILE' => gemfile,
          'BUNDLE_IGNORE_CONFIG' => nil
        }
      end
    end
  end
end
