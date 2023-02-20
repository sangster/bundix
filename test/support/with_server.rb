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
    thr = Thread.new do
      conn = server.accept
      until (line = conn.readline) == "\r\n"
        @request << line
      end

      conn.write(
        "HTTP/1.1 200 OK\r\n" \
        "Content-Length: #{returning_content.length}\r\n" \
        "Content-Type: text/plain\r\n" \
        "\r\n" \
        "#{returning_content}"
      )

      conn.close
    end

    yield(port_num)
  ensure
    server.close
    thr.join
  end
end
