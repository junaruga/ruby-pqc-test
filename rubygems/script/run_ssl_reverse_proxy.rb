#!/usr/bin/env ruby
# frozen_string_literal: true

# SSL/TLS reverse proxy server for RubyGems.
# Accepts HTTPS connections and forwards them to an HTTP backend server.

require 'socket'
require 'openssl'

# Proxy server configuration
LISTEN_HOST = '127.0.0.1'
LISTEN_PORT = 8443

# Backend HTTP server configuration
BACKEND_HOST = '127.0.0.1'
BACKEND_PORT = 8089

# SSL certificate paths
TOP_DIR = File.expand_path('..', __dir__)
CERT_PATH = File.join(TOP_DIR, 'server', 'ssl', 'rsa.crt')
KEY_PATH = File.join(TOP_DIR, 'server', 'ssl', 'rsa.key')

# Safely close a socket, ignoring any errors.
def safe_close(socket)
  socket&.close
rescue StandardError
  nil
end

# Copy data between streams, ignoring errors on disconnect.
def copy_stream_safe(src, dst)
  IO.copy_stream(src, dst)
rescue StandardError
  nil
end

# Handle a single client connection by proxying to the backend.
def handle_client(client)
  # Connect to the backend HTTP server
  backend = TCPSocket.new(BACKEND_HOST, BACKEND_PORT)

  # Bidirectional copy: client -> backend and backend -> client
  t1 = Thread.new { copy_stream_safe(client, backend) }
  t2 = Thread.new { copy_stream_safe(backend, client) }
  [t1, t2].each(&:join)
rescue StandardError => e
  warn "Connection error: #{e.class}: #{e.message}"
ensure
  safe_close(client)
  safe_close(backend)
end

# Set up SSL context with certificate and TLS 1.3
ctx = OpenSSL::SSL::SSLContext.new
ctx.cert = OpenSSL::X509::Certificate.new(File.read(CERT_PATH))
ctx.key = OpenSSL::PKey.read(File.read(KEY_PATH))
ctx.min_version = OpenSSL::SSL::TLS1_3_VERSION

# Create TCP server and wrap it with SSL
tcp = TCPServer.new(LISTEN_HOST, LISTEN_PORT)
ssl = OpenSSL::SSL::SSLServer.new(tcp, ctx)

puts "TLS proxy: https://#{LISTEN_HOST}:#{LISTEN_PORT} -> " \
     "http://#{BACKEND_HOST}:#{BACKEND_PORT}"

# Main loop: accept connections and handle each in a new thread
loop do
  client = ssl.accept
  Thread.new(client) { |c| handle_client(c) }
end
