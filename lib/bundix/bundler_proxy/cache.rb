# frozen_string_literal: true

require 'bundler/cli'
require 'bundler/cli/cache'

module Bundix
  module BundlerProxy
    # Executes +bundle cache --all+.
    class Cache < Base
      attr_reader :all_sources, :gemfile, :path

      # @param [#to_s] The directory to store cached gems into.
      def initialize(path, gemfile, all_sources: true, **kwargs)
        super(**kwargs)
        @path = path
        @gemfile = gemfile
        @all_sources = all_sources
      end

      protected

      def cli
        Bundler::CLI::Cache
          .new('all-platforms' => false, # TODO: get from CLI args
               'cache-path' => cache_dir,
               all: all_sources,
               path: path,
               gemfile: gemfile)
      end

      def env
        {
          'BUNDLE_PATH' => cache_dir,
          'BUNDLE_GEMFILE' => gemfile
        }
      end
    end
  end
end
