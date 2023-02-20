# frozen_string_literal: true

class Bundix
  class Fetcher
    def sh(...)
      Bundix.sh(...)
    end

    def download(file, url)
      warn "Downloading #{file} from #{url}"
      uri = URI(url)

      case uri.scheme
      when nil # local file path
        FileUtils.cp(url, file)
      when 'http', 'https'
        inject_credentials_from_bundler_settings(uri) unless uri.user

        Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
          request = Net::HTTP::Get.new(uri)
          request.basic_auth(uri.user, uri.password) if uri.user

          http.request(request) do |resp|
            case resp
            when Net::HTTPOK
              File.open(file, 'wb+') do |local|
                resp.read_body { |chunk| local.write(chunk) }
              end
            when Net::HTTPUnauthorized, Net::HTTPForbidden
              debrief_access_denied(uri.host)
              raise "http error #{resp.code}: #{uri.host}"
            else
              raise "http error #{resp.code}: #{uri.host}"
            end
          end
        end
      else
        raise 'Unsupported URL scheme'
      end
    end

    def inject_credentials_from_bundler_settings(uri)
      @bundler_settings ||= Bundler::Settings.new("#{Bundler.root}.bundle")

      if val = @bundler_settings[uri.host]
        uri.user, uri.password = val.split(':', 2)
      end
    end

    def debrief_access_denied(host)
      print_error(
        "Authentication is required for #{host}.\n" \
        "Please supply credentials for this source. You can do this by running:\n " \
        'bundle config packages.shopify.io username:password'
      )
    end

    def print_error(msg)
      msg = "\x1b[31m#{msg}\x1b[0m" if $stdout.tty?
      warn(msg)
    end

    def nix_prefetch_url(url)
      dir = File.join(ENV['XDG_CACHE_HOME'] || "#{Dir.home}/.cache", 'bundix')
      FileUtils.mkdir_p dir
      file = File.join(dir, url.gsub(/[^\w-]+/, '_'))

      download(file, url) unless File.size?(file)
      return unless File.size?(file)

      sh(
        Bundix::NIX_PREFETCH_URL,
        '--type', 'sha256',
        '--name', File.basename(url), # --name mygem-1.2.3.gem
        "file://#{file}"              # file:///.../https_rubygems_org_gems_mygem-1_2_3_gem
      ).force_encoding('UTF-8').strip
    rescue StandardError => e
      warn(e.full_message)
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

      sh(NIX_PREFETCH_GIT, *args)
    ensure
      ENV['HOME'] = home
    end

    def format_hash(hash)
      sh(NIX_HASH, '--type', 'sha256', '--to-base32', hash)[SHA256_32]
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

    def fetch_remotes_hash(spec, remotes)
      remotes.each do |remote|
        hash = fetch_remote_hash(spec, remote)
        return remote, format_hash(hash) if hash
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
