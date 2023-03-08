# frozen_string_literal: true

require 'base64'

RSpec.describe Bundix::Fetcher do
  subject(:cmd) { described_class.new(bundler_settings: bundler_settings) }

  let(:bundler_settings) { nil }

  describe '#download' do
    let(:file) { 'some-file' }

    around do |test|
      old_verbose = $VERBOSE
      $VERBOSE = true
      test.call
      $VERBOSE = old_verbose
    end

    context 'without bundler credentials' do
      include_context 'with dir and server'

      it 'outputting logging only to STDERR' do
        expect { cmd.download(file, uri) }.to output('').to_stdout.and(
          output(/Downloading #{file} from http:.*/).to_stderr
        )
      end

      it 'does not send an Authorization HTTP header' do
        cmd.download(file, uri)
        expect(request).not_to include 'Authorization:'
      end
    end

    context 'with bundler credentials' do
      include_context 'with dir and server', bundler_credential: 'secret'

      let(:encoded_secret) { Base64.encode64('secret:').chomp }

      it 'authorizes using the bundler credentials' do
        cmd.download(file, uri)
        expect(request).to include "Authorization: Basic #{encoded_secret}"
      end
    end
  end
end
