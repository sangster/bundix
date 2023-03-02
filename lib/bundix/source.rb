# frozen_string_literal: true

module Bundix
  # Represents a {Bundler::Source} and a means to calculate its SHA-256 hash
  # (where applicable) and other build parameters.
  #
  # The nix function, +bundlerEnv+, uses +buildRubyGem+ to fetch and build the
  # derivation representing a single gem dependency. This service generates the
  # function arguments necessary for +buildRubyGem+ to build the given source.
  #
  # = Supported source types
  #
  # - {Bundler::Source::Git}
  # - {Bundler::Source::Path}
  # - {Bundler::Source::Rubygems}
  #
  # @see https://github.com/NixOS/nixpkgs/blob/6ff8c02/pkgs/development/ruby-modules/gem/default.nix
  class Source
    attr_reader :fetcher, :spec

    # @param spec [Bundler::Source]
    # @param fetcher [Fetcher]
    def initialize(spec, fetcher)
      @spec = spec
      @fetcher = fetcher
    end

    # @return [Hash] The attributes neccessary for the nix function,
    #   +buildRubyGem+, to fetch and build {#spec}.
    def convert
      case spec.source
      when Bundler::Source::Git then convert_git
      when Bundler::Source::Path then convert_path
      when Bundler::Source::Rubygems then convert_rubygems
      else
        raise "unknown bundler source: #{spec.inspect}"
      end
    end

    private

    def convert_git
      hash = fetch_git_hash
      puts "#{hash} => #{source_uri}" if $VERBOSE

      { type: 'git',
        url: source_uri.to_s,
        rev: source_revision,
        sha256: hash,
        fetchSubmodules: submodules? }
    end

    def fetch_git_hash
      output = fetcher.nix_prefetch_git(source_uri, source_revision, submodules: submodules?)

      # FIXME: this is a hack, we should separate $stdout/$stderr in the sh call
      JSON.parse(output[/({[^}]+})\s*\z/m])['sha256'].tap do |hash|
        raise "couldn't fetch hash for #{spec.full_name}" unless hash
      end
    end

    def source_revision
      @source_revision ||= spec.source.options.fetch('revision')
    end

    def source_uri
      @source_uri ||= spec.source.options.fetch('uri')
    end

    def submodules?
      !spec.source.submodules.nil?
    end

    def convert_path
      {
        type: 'path',
        path: spec.source.path
      }
    end

    def convert_rubygems
      remote, hash = fetch_remote_hashes
      puts "#{hash} => #{spec.full_name}.gem" if $VERBOSE

      { type: 'gem',
        remotes: (remote ? [remote] : remotes),
        sha256: hash }
    end

    def fetch_remote_hashes
      hash = fetcher.fetch_local_hash(spec)
      remote, hash = fetcher.fetch_remotes_hash(spec, remotes) unless hash
      raise "couldn't fetch hash for #{spec.full_name}" unless hash

      [remote, hash]
    end

    def remotes
      @remotes ||= spec.source.remotes.map { |remote| remote.to_s.sub(%r{/+$}, '') }
    end
  end
end
