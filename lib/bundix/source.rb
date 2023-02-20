# frozen_string_literal: true

module Bundix
  Source = Struct.new(:spec, :fetcher) do
    def convert
      case spec.source
      when Bundler::Source::Rubygems
        convert_rubygems
      when Bundler::Source::Git
        convert_git
      when Bundler::Source::Path
        convert_path
      else
        pp spec
        raise 'unknown bundler source'
      end
    end

    def convert_path
      {
        type: 'path',
        path: spec.source.path
      }
    end

    def convert_rubygems
      remotes = spec.source.remotes.map { |remote| remote.to_s.sub(%r{/+$}, '') }
      hash = fetcher.fetch_local_hash(spec)
      remote, hash = fetcher.fetch_remotes_hash(spec, remotes) unless hash
      raise "couldn't fetch hash for #{spec.full_name}" unless hash

      puts "#{hash} => #{spec.full_name}.gem" if $VERBOSE

      { type: 'gem',
        remotes: (remote ? [remote] : remotes),
        sha256: hash }
    end

    def convert_git
      revision = spec.source.options.fetch('revision')
      uri = spec.source.options.fetch('uri')
      submodules = !spec.source.submodules.nil?
      output = fetcher.nix_prefetch_git(uri, revision, submodules: submodules)
      # FIXME: this is a hack, we should separate $stdout/$stderr in the sh call
      hash = JSON.parse(output[/({[^}]+})\s*\z/m])['sha256']
      raise "couldn't fetch hash for #{spec.full_name}" unless hash

      puts "#{hash} => #{uri}" if $VERBOSE

      { type: 'git',
        url: uri.to_s,
        rev: revision,
        sha256: hash,
        fetchSubmodules: submodules }
    end
  end
end
