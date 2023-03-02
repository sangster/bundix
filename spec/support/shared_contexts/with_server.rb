# frozen_string_literal: true

# Runs a temporary HTTP server which responds to a single request.
RSpec.shared_context 'with server' do |returning_content:|
  let(:request) { String.new }
  let(:server) { TCPServer.new('127.0.0.1', 0) }
  let(:port_num) { server.addr[1] }

  def single_request(server, returning_content)
    conn = server.accept
    until (line = conn.readline) == "\r\n"
      request << line
    end

    conn.write(plain_response(returning_content))
    conn.close
  end

  def plain_response(body)
    [
      'HTTP/1.1 200 OK',
      "Content-Length: #{body.length}",
      'Content-Type: text/plain',
      '',
      body
    ].join("\r\n")
  end

  around do |test|
    Thread.abort_on_exception = true
    thr = Thread.new { single_request(server, returning_content) }

    test.call
  ensure
    server.close
    thr.join
  end
end
