# frozen_string_literal: true

module Bundix
  # This fetcher fetches gems from HTTP and HTTPS sources.
  class HttpFetcher
    def download(file, uri)
      raise ArgumentError, "unexpected scheme: #{uri.scheme}" unless %w[http https].include?(uri.scheme)

      inject_credentials_from_bundler_settings(uri) unless uri.user
      make_request uri do |resp|
        File.open(file, 'wb+') do |local|
          resp.read_body { |chunk| local.write(chunk) }
        end
      end
    end

    private

    def inject_credentials_from_bundler_settings(uri)
      @bundler_settings ||= Bundler::Settings.new(Bundler.root.join('.bundle'))

      return unless (val = @bundler_settings[uri.host])

      uri.user, uri.password = val.split(':', 2)
    end

    def make_request(uri, &blk)
      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(uri.user, uri.password) if uri.user
        http.request(request) { |resp| handle_response(resp, &blk) }
      end
    end

    def handle_response(resp)
      case resp
      when Net::HTTPOK
        yield resp
      when Net::HTTPUnauthorized, Net::HTTPForbidden
        debrief_access_denied(uri.host)
        raise "http error #{resp.code}: #{uri.host}"
      else
        raise "http error #{resp.code}: #{uri.host}"
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
  end
end
