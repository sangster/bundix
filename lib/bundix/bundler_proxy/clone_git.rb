# frozen_string_literal: true

require 'bundler/cli'
require 'bundler/cli/lock'

module Bundix
  module BundlerProxy
    # This service ensures a git source is cloned within {#cache_dir}.
    class CloneGit < Base
      attr_reader :ignore_config, :original_source

      # @param original_source [Bundler::Source::Git]
      def initialize(original_source, ignore_config: false, **kwargs)
        super(pipe_result: true, **kwargs)

        @original_source = original_source
        @ignore_config = ignore_config
      end

      protected

      def bundler_process
        dup_source(original_source).tap do |source|
          git_proxy(source).checkout unless source.cache_path.exist?
        end
      end

      def env
        {
          # TODO: 'BUNDLE_FROZEN' => nil,
          'BUNDLE_PATH' => cache_dir,
          'BUNDLE_IGNORE_CONFIG' => (ignore_config ? 'true' : nil)
        }
      end

      private

      # We must dup the source inside #{with_bundler_env}, so its paths are
      # inside {#cache_dir}.
      def dup_source(source)
        Bundler::Source::Git.new(source.options).tap do |new_source|
          new_source.cache_path # memoize path inside {#cache_dir}
          new_source.install_path # memoize path inside {#cache_dir}
          new_source.remote! # allow repo to be cloned
        end
      end

      def git_proxy(source)
        @git_proxy ||= Bundler::Source::Git::GitProxy.new(
          source.cache_path,
          source.uri,
          source.options,
          source.options['revision'],
          source
        )
      end
    end
  end
end
