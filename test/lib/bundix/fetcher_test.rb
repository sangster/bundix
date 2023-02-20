# frozen_string_literal: true

require_relative '../../test_helper'
require 'base64'

module Bundix
  class FetcherTest < UnitTest
    include WithDir
    include WithServer

    def test_download_with_credentials
      with_dir(bundler_credential: 'secret') do |dir|
        with_server(returning_content: 'ok') do |port|
          file = 'some-file'

          assert_equal(File.realpath(dir), Bundler.root.to_s)

          out, err = capture_io do
            Bundix::Fetcher.new.download(file, "http://127.0.0.1:#{port}/test")
          end

          assert_includes(@request, "Authorization: Basic #{Base64.encode64('secret:').chomp}")
          assert_equal(File.read(file), 'ok')
          assert_empty(out)
          assert_match(/^Downloading .* from http.*$/, err)
        end
      end
    end

    def test_download_without_credentials
      with_dir(bundler_credential: nil) do |dir|
        with_server(returning_content: 'ok') do |port|
          file = 'some-file'

          assert_equal(File.realpath(dir), Bundler.root.to_s)

          out, err = capture_io do
            Bundix::Fetcher.new.download(file, "http://127.0.0.1:#{port}/test")
          end

          refute_includes(@request, 'Authorization:')
          assert_equal(File.read(file), 'ok')
          assert_empty(out)
          assert_match(/^Downloading .* from http.*$/, err)
        end
      end
    end
  end
end
