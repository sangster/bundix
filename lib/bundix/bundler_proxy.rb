# frozen_string_literal: true

require 'bundler/cli'
require 'bundler/cli/cache'

module Bundix
  module BundlerProxy
    # A base class for services which execute Bundler CLI classes.
    #
    # The reason for executing bundle CLI aps via its {Bundler} ruby library,
    # instead of the +bundle+ executable, is that +bundle+ will often quit early
    # if sources haven't yet been fetched. +bundle+ will recommend that you
    # execute +bundle install+ to fetch those sources; however +bundle install+
    # may fail if it needs to build native gems (which is +bundlerEnv+'s job).
    class Base
      attr_reader :cache_dir

      # @param cache_dir [#to_s] The local directory where Bundix caches gems
      #   and other fetched sources.
      def initialize(cache_dir: CACHE_DIR)
        @cache_dir = cache_dir
      end

      def call
        # We fork here because Bundler may instance_exec some .gemspec files,
        # and those file may require other ruby files. We don't want them affect
        # the ruby process running this app.
        Process.wait(fork { with_bundler_env { cli.run } })
      end

      protected

      # @return [#run] The {Bundler::CLI} service to execute.
      def cli
        raise NotImplementedError
      end

      # @return [Hash] The modified {ENV} to run the Bundler CLI application in.
      def env
        {}
      end

      private

      def with_bundler_env
        System.temp_env(**env) do
          Bundler.reset!
          monkey_patch_definition(Bundler.definition)
          yield
        end
      end

      def monkey_patch_definition(definition)
        # Stop Bundler from complaining about the host system's ruby version or
        # platform being different than the Gemfile specifies. We're not using
        # Bundler to load rubygems, so we don't need these to match.
        definition.define_singleton_method(:validate_runtime!) { true }
      end
    end
  end
end
