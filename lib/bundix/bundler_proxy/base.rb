# frozen_string_literal: true

require 'bundler/cli'
require 'bundler/cli/cache'

module Bundix
  module BundlerProxy
    # A base class for services which execute inside a modified Bundler
    # environment.
    #
    # The {Bundler} library does complicated things with {ENV} and frequently
    # modifies singleton data. Bundix uses Bundler for two purposes:
    #
    #   1. To handle the user's +Gemfile+ and +Gemfile.lock+.
    #   2. To load its own rubygem dependencies, like a typical ruby project.
    #
    # When handling user files, it's possible that they may break the instance
    # of {Bundler} which Bundix is using for its own purposes. To avoid this, we
    # spawn a child process to act as a sandbox. Inside the child process,
    # {Bundler} can modify what it likes without affecting the parent process.
    class Base
      attr_reader :cache_dir, :pipe_result

      # @param cache_dir [#to_s] The local directory where Bundix caches gems
      #   and other fetched sources.
      def initialize(cache_dir: CACHE_DIR, pipe_result: false)
        @cache_dir = cache_dir
        @pipe_result = pipe_result
      end

      def call
        # We fork here because Bundler may instance_exec some .gemspec files,
        # and those file may require other ruby files. We don't want them affect
        # the ruby process running this app.
        pipe_result ? do_fork_with_result : do_fork
      end

      protected

      def bundler_process
        raise NotImplementedError
      end

      # @return [Hash] The modified {ENV} to run the Bundler CLI application in.
      def env
        {}
      end

      private

      def do_fork_with_result
        read, write = IO.pipe

        pid = fork do
          read.close
          Marshal.dump(with_bundler_env { bundler_process }, write)
        end

        write.close
        result = read.read
        Process.wait(pid)
        raise ProcessError, 'child failed' if result.empty?

        Marshal.load(result) # rubocop:disable Security/MarshalLoad
      end

      def do_fork
        Process.wait(fork { with_bundler_env { bundler_process } })
        nil
      end

      def with_bundler_env
        Bundler.with_unbundled_env do
          System.temp_env(env) do
            Bundler.reset!
            monkey_patch_definition(Bundler.definition)
            yield
          end
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
