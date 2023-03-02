# frozen_string_literal: true

RSpec.shared_context 'with dir and server' do |bundler_credential: nil,
                                               returning_content: 'ok'|
  include_context 'with dir', bundler_credential: bundler_credential
  include_context 'with server', returning_content: returning_content

  let(:uri) { "http://127.0.0.1:#{port_num}/test" }
end
