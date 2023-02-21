# frozen_string_literal: true

module Bundix
  # Fetches gems from local and remote sources.
  class Fetcher
    def download(file, url)
      warn "Downloading #{file} from #{url}"
      uri = URI(url)

      case uri.scheme
      when nil # local file path
        FileUtils.cp(url, file)
      when 'http', 'https'
        HttpFetcher.new.download(file, uri)
      else
        raise 'Unsupported URL scheme'
      end
    end

    def fetch_remotes_hash(spec, remotes)
      remotes.each do |remote|
        hash = fetch_remote_hash(spec, remote)
        return remote, format_hash(hash) if hash
      end

      nil
    end

    def nix_prefetch_git(uri, revision, submodules: false)
      home = Dir.home
      ENV['HOME'] = '/homeless-shelter'

      args = []
      args << '--url' << uri
      args << '--rev' << revision
      args << '--hash' << 'sha256'
      args << '--fetch-submodules' if submodules

      Shell.sh(NIX_PREFETCH_GIT, *args)
    ensure
      ENV['HOME'] = home
    end

    private

    def nix_prefetch_url(url)
      dir = File.join(ENV['XDG_CACHE_HOME'] || "#{Dir.home}/.cache", 'bundix')
      FileUtils.mkdir_p(dir)
      file = File.join(dir, url.gsub(/[^\w-]+/, '_'))

      download(file, url) unless File.size?(file)
      return unless File.size?(file)

      system_prefetch_url(url, file)
    rescue StandardError => e
      warn(e.full_message)
      nil
    end

    def system_prefetch_url(url, file)
      Shell.sh(
        NIX_PREFETCH_URL,
        '--type', 'sha256',
        '--name', File.basename(url), # --name mygem-1.2.3.gem
        "file://#{file}"              # file:///.../https_rubygems_org_gems_mygem-1_2_3_gem
      ).force_encoding('UTF-8').strip
    end

    def format_hash(hash)
      Shell.sh(NIX_HASH, '--type', 'sha256', '--to-base32', hash)[SHA256_32]
    end

    def fetch_local_hash(spec)
      spec.source.caches.each do |cache|
        path = File.join(cache, "#{spec.full_name}.gem")
        next unless File.file?(path)

        hash = nix_prefetch_url(path)&.[](SHA256_32)
        return format_hash(hash) if hash
      end

      nil
    end

    def fetch_remote_hash(spec, remote)
      uri = "#{remote}/gems/#{spec.full_name}.gem"
      result = nix_prefetch_url(uri)
      return unless result

      result[SHA256_32]
    rescue StandardError => e
      puts "ignoring error during fetching: #{e}"
      puts e.backtrace
      nil
    end
  end
end
