# frozen_string_literal: true

require 'net/http'

module Bundix
  # This fetcher fetches gems from HTTP and HTTPS sources.
  class HttpFetcher
    attr_reader :bundler_settings, :uri

    # @param uri [URI] The URI of the gem to fetch.
    # @param bundler_settings [Bundler::Settings,nil] Optional bundler settings
    #   to provide HTTP credentials.
    def initialize(uri, bundler_settings: nil)
      raise ArgumentError, "unexpected scheme: #{uri.scheme}" unless %w[http https].include?(uri.scheme)

      @uri = uri
      @bundler_settings = bundler_settings
    end

    # @param dest [#to_s] The filename to save the downloaded gem to.
    def download(dest)
      inject_credentials_from_bundler_settings unless uri.user
      make_request do |resp|
        File.open(dest.to_s, 'wb+') do |local|
          resp.read_body { |chunk| local.write(chunk) }
        end
      end
    end

    private

    def inject_credentials_from_bundler_settings
      creds = bundler_settings&.credentials_for(uri)
      return unless creds

      uri.user, uri.password = creds.split(':', 2)
    end

    def make_request(&blk)
      http_start do |http|
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(uri.user, uri.password) if uri.user
        http.request(request) { |resp| handle_response(resp, &blk) }
      end
    end

    def http_start(&blk)
      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https'),
                      &blk)
    end

    def handle_response(resp)
      case resp
      when Net::HTTPOK
        yield resp
      when Net::HTTPUnauthorized, Net::HTTPForbidden
        debrief_access_denied
        raise "http error #{resp.code}: #{uri.host}"
      else
        raise "http error #{resp.code}: #{uri.host}"
      end
    end

    def debrief_access_denied
      print_error(
        "Authentication is required for #{uri.host}.\n" \
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
