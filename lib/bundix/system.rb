# frozen_string_literal: true

require 'open3'

module Bundix
  # Helper methods for executing system processes.
  class System
    NIX = 'nix'
    NIX_PREFETCH_GIT = 'nix-prefetch-git'
    NIX_PREFETCH_URL = 'nix-prefetch-url'

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

      # Executes {NIX} to convert the given nix file to JSON.
      # @param nix_file [#to_s] Path to a nix file.
      # @return [String]
      def nix_to_json(nix_file)
        sh(NIX, 'eval', '--impure', '--json', '-f', nix_file.to_s).strip
      end

      # Temporarily modify {ENV} for the duration of the given block.
      def temp_env(**env)
        prev_env = env.to_h { |k, _| [k, ENV.fetch(k, nil)] }
        env.each { |k, v| ENV[k] = v }
        yield
      ensure
        prev_env.each { |k, v| ENV[k] = v }
      end
    end
  end
end
