# frozen_string_literal: true

require 'bundler/cli'
require 'bundler/cli/lock'

module Bundix
  #
  class BundlerLock
    attr_reader :cache_dir, :gemfile, :lockfile, :update
    attr_accessor :add_platforms, :remove_platforms

    def initialize(gemfile, lockfile, update: false, cache_dir: CACHE_DIR)
      @gemfile = gemfile
      @lockfile = lockfile
      @update = update
      @cache_dir = cache_dir
      @add_platforms = []
      @remove_platforms = []
    end

    def call
      # We fork here because Bundler may instance_exec some .gemspec files, and
      # those file may require other ruby files. We don't want them affect the
      # ruby process running this app.
      Process.wait(fork { with_bundler_env { cli_lock.run } })
    end

    private

    def with_bundler_env
      System.temp_env(**env) do
        Bundler.reset!
        yield
      end
    end

    def env
      {
        'BUNDLE_FROZEN' => nil,
        'BUNDLE_PATH' => cache_dir,
        'BUNDLE_GEMFILE' => gemfile,
      }
    end

    def cli_lock
      Bundler::CLI::Lock
        .new('remove-platform' => remove_platforms,
             'add-platform' => add_platforms,
             lockfile: lockfile,
             gemfile: gemfile,
             update: update)
    end
  end
end
