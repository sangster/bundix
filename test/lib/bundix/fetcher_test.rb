# frozen_string_literal: true

require_relative '../../test_helper'
require 'base64'

class FetcherTest < UnitTest
  include WithDir
  include WithServer

  def setup
    $VERBOSE = true
  end

  def test_download_with_credentials
    with_dir_and_server(bundler_credential: 'secret') do |uri|
      file = 'some-file'

      out, err = capture_io { Bundix::Fetcher.new.download(file, uri) }

      assert_includes(@request, "Authorization: Basic #{Base64.encode64('secret:').chomp}")
      assert_equal('ok', File.read(file))
      assert_empty(out)
      assert_match(/^Downloading .* from http.*$/, err)
    end
  end

  def test_download_without_credentials
    with_dir_and_server do |uri|
      file = 'some-file'

      out, err = capture_io { Bundix::Fetcher.new.download(file, uri) }

      refute_includes(@request, 'Authorization:')
      assert_equal('ok', File.read(file))
      assert_empty(out)
      assert_match(/^Downloading .* from http.*$/, err)
    end
  end

  private

  def with_dir_and_server(bundler_credential: nil)
    with_dir(bundler_credential: bundler_credential) do |dir|
      with_server(returning_content: 'ok') do |port|
        assert_equal(File.realpath(dir), Bundler.root.to_s)

        yield "http://127.0.0.1:#{port}/test"
      end
    end
  end
end
