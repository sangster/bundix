# frozen_string_literal: true

require 'bundler/cli'
require 'bundler/cli/cache'

module Bundix
  module BundlerProxy
    # Executes +bundle cache --all+.
    #
    # The reason for executing this via the {Bundler} ruby library, instead of
    # the +bundle+ executable, is that +bundle+ may quit early if any git
    # sources haven't yet been cloned. +bundle+ will then recommend that you
    # execute +bundle install+ to fetch them; however +bundle install+ may fail
    # if it needs to build native gems (which is +bundlerEnv+'s job).
    class Cache < Base
      attr_reader :all_sources, :gemfile, :path

      # @param path [#to_s] The directory to store cached gems into.
      # @param gemfile [#to_s] Path to the +Gemfile+.
      def initialize(path, gemfile, all_sources: true, **kwargs)
        super(**kwargs)
        @path = path
        @gemfile = gemfile
        @all_sources = all_sources
      end

      protected

      def bundler_process
        cli.run
      end

      def env
        {
          'BUNDLE_PATH' => cache_dir,
          'BUNDLE_GEMFILE' => gemfile
        }
      end

      private

      def cli
        Bundler::CLI::Cache
          .new('all-platforms' => false, # TODO: get from CLI args
               'cache-path' => cache_dir,
               all: all_sources,
               path: path,
               gemfile: gemfile)
      end
    end
  end
end
