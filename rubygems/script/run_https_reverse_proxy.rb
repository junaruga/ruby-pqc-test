#!/usr/bin/env ruby
# frozen_string_literal: true

# SSL/TLS reverse proxy server for RubyGems.
# Accepts HTTPS connections and forwards them to an HTTP backend server.

require 'optparse'
require 'socket'
require 'openssl'

# Proxy server configuration
LISTEN_HOST = '127.0.0.1'
LISTEN_PORT = 18_443

# Backend HTTP server configuration
BACKEND_HOST = '127.0.0.1'
BACKEND_PORT = 18_808

TOP_DIR = File.expand_path('..', __dir__)
SSL_DIR = File.join(TOP_DIR, 'server', 'ssl')

pqc_dual = false
pqc_single = false
OptionParser.new do |opts|
  opts.on('-d', '--pqc-dual', 'Enable dual RSA + ML-DSA-65 certificates') do
    pqc_dual = true
  end
  opts.on('-s', '--pqc-single', 'Enable PQC single cert mode') do
    pqc_single = true
  end
end.parse!

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

rsa_cert_file = File.join(SSL_DIR, 'rsa-2.crt')
rsa_key_file = File.join(SSL_DIR, 'rsa-2.key')
rsa_cert = OpenSSL::X509::Certificate.new(File.read(rsa_cert_file))
rsa_key = OpenSSL::PKey.read(File.read(rsa_key_file))
mldsa65_cert_file = File.join(SSL_DIR, 'mldsa65-2.crt')
mldsa65_key_file = File.join(SSL_DIR, 'mldsa65-2.key')
mldsa65_cert = OpenSSL::X509::Certificate.new(
  File.read(mldsa65_cert_file)
)
mldsa65_key = OpenSSL::PKey.read(File.read(mldsa65_key_file))

# Start an accept loop for a given SSL server.
def run_accept_loop(ssl)
  loop do
    client = ssl.accept
    Thread.new(client) { |c| handle_client(c) }
  rescue OpenSSL::SSL::SSLError => e
    warn "SSL accept error: #{e.message}"
  end
end

if pqc_single
  pqc_ctx = OpenSSL::SSL::SSLContext.new
  pqc_ctx.min_version = OpenSSL::SSL::TLS1_3_VERSION
  pqc_ctx.sigalgs = 'mldsa65'
  pqc_ctx.add_certificate(mldsa65_cert, mldsa65_key)

  non_pqc_ctx = OpenSSL::SSL::SSLContext.new
  non_pqc_ctx.min_version = OpenSSL::SSL::TLS1_3_VERSION
  non_pqc_ctx.cert = rsa_cert
  non_pqc_ctx.key = rsa_key

  pqc_tcp = TCPServer.new(LISTEN_HOST, LISTEN_PORT)
  pqc_ssl = OpenSSL::SSL::SSLServer.new(pqc_tcp, pqc_ctx)

  non_pqc_port = 18_444
  non_pqc_tcp = TCPServer.new(LISTEN_HOST, non_pqc_port)
  non_pqc_ssl = OpenSSL::SSL::SSLServer.new(non_pqc_tcp, non_pqc_ctx)

  puts "TLS proxy (PQC single): https://#{LISTEN_HOST}:#{LISTEN_PORT} -> " \
       "http://#{BACKEND_HOST}:#{BACKEND_PORT}"
  puts 'TLS proxy (non-PQC single): ' \
       "https://#{LISTEN_HOST}:#{non_pqc_port} -> " \
       "http://#{BACKEND_HOST}:#{BACKEND_PORT}"

  Thread.new { run_accept_loop(non_pqc_ssl) }
  run_accept_loop(pqc_ssl)
else
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.min_version = OpenSSL::SSL::TLS1_3_VERSION

  if pqc_dual
    ctx.sigalgs = 'rsa_pss_rsae_sha256:mldsa65'
    ctx.add_certificate(mldsa65_cert, mldsa65_key)
    ctx.add_certificate(rsa_cert, rsa_key)
  else
    ctx.cert = rsa_cert
    ctx.key = rsa_key
  end

  tcp = TCPServer.new(LISTEN_HOST, LISTEN_PORT)
  ssl = OpenSSL::SSL::SSLServer.new(tcp, ctx)

  puts "TLS proxy: https://#{LISTEN_HOST}:#{LISTEN_PORT} -> " \
       "http://#{BACKEND_HOST}:#{BACKEND_PORT}"

  run_accept_loop(ssl)
end
