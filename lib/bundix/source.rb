# frozen_string_literal: true

module Bundix
  Source = Struct.new(:spec, :fetcher) do
    def convert
      case spec.source
      when Bundler::Source::Rubygems then convert_rubygems
      when Bundler::Source::Git then convert_git
      when Bundler::Source::Path then convert_path
      else
        raise "unknown bundler source: #{spec.inspect}"
      end
    end

    private

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
  end
end
