# frozen_string_literal: true

require 'fileutils'

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
        return remote, System.format_hash(hash) if hash
      end

      nil
    end

    def nix_prefetch_git(...)
      System.nix_prefetch_git(...)
    end

    def fetch_local_hash(spec)
      spec.source.caches.each do |cache|
        path = File.join(cache, "#{spec.full_name}.gem")
        next unless File.file?(path)

        hash = nix_prefetch_url(path)&.[](SHA256_32)
        return System.format_hash(hash) if hash
      end

      nil
    end

    def nix_prefetch_url(url)
      dir = File.join(ENV['XDG_CACHE_HOME'] || "#{Dir.home}/.cache", 'bundix')
      FileUtils.mkdir_p(dir)
      file = File.join(dir, url.gsub(/[^\w-]+/, '_'))

      download(file, url) unless File.size?(file)
      return unless File.size?(file)

      System.nix_prefetch_url(url, file)
    rescue StandardError => e
      warn(e.full_message)
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
