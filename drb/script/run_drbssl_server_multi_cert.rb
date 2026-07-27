#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

# Use the modified drb with PQC support from the local repository.
$LOAD_PATH.unshift(File.expand_path('~/git/ruby/drb/lib'))

require 'drb/drb'
require 'drb/ssl'

# The URI for the server to connect to
URI = 'drbssl://localhost:8787'

# A simple time server for testing drbssl.
class TimeServer
  def current_time
    Time.now
  end

  def print_ssl_socket_info
    # OpenSSL::SSL::SSLSocket object
    ssl = Thread.current['DRb']['client'].stream
    puts "server: Group: #{ssl.group}"
    puts "server: Signature Algorithm: #{ssl.sigalg}"
    puts "server: Peer Signature Algorithm: #{ssl.peer_sigalg}"
  end
end

config = {
  SSLCertName: [['C', 'JP'], ['O', 'Foo.DRuby.Org'], ['CN', 'Sample']],
  SSLPrivateKeyAlgorithms: %w[ML-DSA-65 RSA],
  SSLSignatureAlgorithms: 'mldsa65:rsa_pss_rsae_sha256',
  SSLVerifyMode: OpenSSL::SSL::VERIFY_NONE
}

# The object that handles requests on the server
FRONT_OBJECT = TimeServer.new

DRb.start_service(URI, FRONT_OBJECT, config)

# Inspect the generated certificates
server = DRb.primary_server
protocol = server.instance_variable_get(:@protocol)
ssl_config = protocol.instance_variable_get(:@config)
certs = ssl_config.instance_variable_get(:@certs)

certs.each do |cert, pkey|
  puts "server: Key: #{pkey.inspect}"
  puts "server: Signature algorithm: #{cert.signature_algorithm}"
end

# Wait for the drb server thread to finish before exiting.
DRb.thread.join
