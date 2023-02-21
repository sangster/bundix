# frozen_string_literal: true

module Bundix
  # Helper methods for executing system processes.
  class System
    NIX_HASH = 'nix-hash'
    NIX_INSTANTIATE = 'nix-instantiate'
    NIX_PREFETCH_GIT = 'nix-prefetch-git'
    NIX_PREFETCH_URL = 'nix-prefetch-url'
    NIX_SHELL = 'nix-shell'

    class << self
      def sh(*args, &block)
        out, status = Open3.capture2(*args)
        unless block_given? ? block.call(status, out) : status.success?
          puts "$ #{args.join(' ')}" if $VERBOSE
          puts out if $VERBOSE
          raise "command execution failed: #{status}"
        end
        out
      end

      def format_hash(hash)
        sh(NIX_HASH, '--type', 'sha256', '--to-base32', hash)[SHA256_32]
      end

      def nix_prefetch_git(uri, revision, submodules: false)
        old_home = Dir.home
        ENV['HOME'] = '/homeless-shelter'

        args = []
        args << '--url' << uri
        args << '--rev' << revision
        args << '--hash' << 'sha256'
        args << '--fetch-submodules' if submodules

        System.sh(NIX_PREFETCH_GIT, *args)
      ensure
        ENV['HOME'] = old_home
      end

      def prefetch_url(url, file)
        sh(
          NIX_PREFETCH_URL,
          '--type', 'sha256',
          '--name', File.basename(url), # --name mygem-1.2.3.gem
          "file://#{file}"              # file:///.../https_rubygems_org_gems_mygem-1_2_3_gem
        ).force_encoding('UTF-8').strip
      end

      def nix_to_json(path)
        sh(
          NIX_INSTANTIATE, '--eval', '-E',
          "builtins.toJSON (import #{Nixer.serialize(path)})"
        ).strip.gsub(/\\"/, '"')[1..-2]
      end

      def nix_bundle_lock(ruby, lockfile)
        system(
          NIX_SHELL, '-p', ruby,
          "bundler.override { ruby = #{ruby}; }",
          '--command', "bundle lock --lockfile=#{lockfile}"
        )
      end

      def nix_bundle_pack(ruby, bundle_pack_path)
        system(
          NIX_SHELL, '-p', ruby,
          "bundler.override { ruby = #{ruby}; }",
          '--command', "bundle pack --all --path #{bundle_pack_path}"
        )
      end
    end
  end
end
