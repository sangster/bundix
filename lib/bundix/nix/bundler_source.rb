# frozen_string_literal: true

module Bundix
  module Nix
    # {Serializer Serializes} a Bundler spec's source into nix format.
    class BundlerSource
      attr_reader :source, :spec

      def self.build(spec)
        case spec.source
        when Bundler::Source::Git then Git.new(spec)
        when Bundler::Source::Path then Path.new(spec)
        when Bundler::Source::Rubygems then Rubygems.new(spec)
        else
          raise ArgumentError, "unexpected source: #{spec.source}"
        end
      end

      def initialize(spec)
        @spec = spec
        @source = spec.source
      end

      # {Serializer Serializes} a {Bundler::Source::Git} into nix format.
      class Git < BundlerSource
        def self.sha256(spec)
          rev = spec.source.options.fetch('revision')
          System.nix_prefetch_git(spec.source.cache_path, rev)['sha256']
        end

        def to_nix
          {
            type: 'git',
            url: source.options.fetch('uri').to_s,
            rev: source.options.fetch('revision'),
            sha256: self.class.sha256(spec),
            fetchSubmodules: !source.submodules.nil?
          }
        end
      end

      # {Serializer Serializes} a {Bundler::Source::Path} into nix format.
      class Path < BundlerSource
        def to_nix
          {
            type: 'path',
            path: source.path
          }
        end
      end

      # {Serializer Serializes} a {Bundler::Source::Rubygems} into nix format.
      class Rubygems < BundlerSource
        def self.sha256(spec)
          Nix::Hash32.call(spec.checksum)
        end

        def to_nix
          {
            remotes: remotes,
            type: 'gem',
            sha256: self.class.sha256(spec)
          }
        end

        def remotes
          source.remotes.map { |remote| remote.to_s.sub(%r{/+$}, '') }
        end
      end
    end
  end
end
