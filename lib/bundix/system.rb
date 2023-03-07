# frozen_string_literal: true

require 'open3'

module Bundix
  # Helper methods for executing system processes.
  class System
    NIX_INSTANTIATE = 'nix-instantiate'
    NIX_PREFETCH_GIT = 'nix-prefetch-git'
    NIX_PREFETCH_URL = 'nix-prefetch-url'
    NIX_SHELL = 'nix-shell'

    class << self
      # Execute a process and return its STDOUT. If an optional block is given,
      # the process's status and STDOUT will be yielded.
      #
      # @param args [Array<String>] Arguments passed to {Open3.capture2}.
      # @param env [Hash] Environmental variables to pass to the child process.
      #   defaults to {ENV}.
      # @yieldparam status [Process::Status]
      # @yieldparam stdout [String]
      # @yieldreturn [Boolean] +false+ to raise an error.
      # @return [String] The STDOUT of the executed process.
      # @raise [StandardError] If a block is given and it returns falsey value,
      #   or, if no block is given, the process fails.
      def sh(*args, env: ENV, &block)
        stdout, status = Open3.capture2(env, *args)
        unless block_given? ? block.call(status, stdout) : status.success?
          puts "$ #{args.join(' ')}" if $VERBOSE
          puts stdout if $VERBOSE
          raise "command execution failed: #{status}"
        end
        stdout
      end

      # Executes {NIX_PREFETCH_GIT} to prefetch the SHA-256 hash, and other
      # arguments, used by the nix function +buildRubyGem+ to build a gem found
      # at the given git +uri+.
      def nix_prefetch_git(uri, revision, submodules: false)
        old_home = Dir.home
        ENV['HOME'] = '/homeless-shelter'

        args = []
        args << '--url' << uri
        args << '--rev' << revision
        args << '--hash' << 'sha256'
        args << '--fetch-submodules' if submodules

        sh(NIX_PREFETCH_GIT, *args)
      ensure
        ENV['HOME'] = old_home
      end

      # Executes {NIX_PREFETCH_URL} to calculate the SHA-256 hash of the local
      # +file+.
      def nix_prefetch_url(url, file)
        sh(
          NIX_PREFETCH_URL,
          '--type', 'sha256',
          '--name', File.basename(url), # --name mygem-1.2.3.gem
          "file://#{file}"              # file:///.../https_rubygems_org_gems_mygem-1_2_3_gem
        ).force_encoding('UTF-8').strip
      end

      # Executes {NIX_INSTANTIATE} to convert the given gemset file to JSON.
      def nix_gemset_to_json(gemset_path)
        sh(
          NIX_INSTANTIATE, '--eval', '-E',
          "builtins.toJSON (import #{Nix::Serializer.call(gemset_path)})"
        ).strip.gsub(/\\"/, '"')[1..-2]
      end

      # Temporarily modify {ENV} for the duration of the given block.
      def temp_env(**env)
        prev_env = env.to_h { |k, _| [k, ENV.fetch(k, nil)] }
        env.each { |k, v| ENV[k] = v }
        yield
      ensure
        prev_env.each { |k, v| ENV[k] = v }
      end

      # Uses {NIX_SHELL} to execute +bundle cache+ in the given +ruby+ version.
      #
      # +bundle cache+ copies +.gem+ files into the +vendor/cache+ directory.
      def nix_bundle_cache(ruby, bundle_cache_path)
        nix_bundler(ruby, "bundle cache --all --path '#{bundle_cache_path}'")
      end

      def nix_bundler(ruby, cmd, **kwargs)
        pp cmd
        sh(
          NIX_SHELL, '-p', ruby,
          "bundler.override { ruby = #{ruby}; }",
          '--command', cmd,
          **kwargs
        )
      end
    end
  end
end
