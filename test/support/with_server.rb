# frozen_string_literal: true

require 'socket'

module WithServer
  # Run an HTTP server for a single request.
  # @yieldparam port [Integer] The port the HTTP server is listening on.
  def with_server(returning_content:)
    server = TCPServer.new('127.0.0.1', 0)
    port_num = server.addr[1]

    @request = String.new

    Thread.abort_on_exception = true
    thr = Thread.new { single_request(server, returning_content) }

    yield(port_num)
  ensure
    server.close
    thr.join
  end

  private

  def single_request(server, returning_content)
    conn = server.accept
    until (line = conn.readline) == "\r\n"
      @request << line
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
end
