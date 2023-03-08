# frozen_string_literal: true

require 'fileutils'

module Bundix
  # Fetches gems from local and remote sources.
  class Fetcher
    attr_reader :bundler_settings

    # @param bundler_settings [Bundler::Settings,nil] Optional bundler settings
    #   to provide credentials for remote fetchers.
    def initialize(bundler_settings: nil)
      @bundler_settings = bundler_settings
    end

    # @param dest [#to_s] The filename to save the downloaded gem to.
    # @param url [URI,String] The HTTP, HTTPS, or local file to download.
    def download(dest, url)
      warn "Downloading #{dest} from #{url}"
      uri = URI(url)

      case uri.scheme
      when nil # local file path
        FileUtils.cp(url, dest.to_s)
      when 'http', 'https'
        HttpFetcher.new(uri, bundler_settings: bundler_settings).download(dest)
      else
        raise 'Unsupported URL scheme'
      end
    end

    def fetch_remotes_hash(spec, remotes)
      remotes.each do |remote|
        hash = fetch_remote_hash(spec, remote)
        return remote, Nix::Hash32.call(hash) if hash
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
        return Nix::Hash32.call(hash) if hash
      end

      nil
    end

    def nix_prefetch_url(url, dir: CACHE_DIR)
      FileUtils.mkdir_p(dir.to_s)
      file = File.join(dir.to_s, url.gsub(/[^\w-]+/, '_'))

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
