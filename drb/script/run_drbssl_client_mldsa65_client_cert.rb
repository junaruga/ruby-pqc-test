#!/usr/bin/env ruby
# frozen_string_literal: true

require 'drb/drb'
require 'drb/ssl'

# The URI to connect to
SERVER_URI = 'drbssl://localhost:8787'

# Start a local DRbServer to handle callbacks.

# Not necessary for this small example, but will be required
# as soon as we pass a non-marshallable object as an argument
# to a dRuby call.

# NOTE: this must be called at least once per process to take any effect.
# This is particularly important if your application forks.
config = {
  SSLCertificate: OpenSSL::X509::Certificate.new(File.read('client/ssl/mldsa65-3.crt')),
  SSLPrivateKey: OpenSSL::PKey.read(File.read('client/ssl/mldsa65-3.key')),
  SSLCACertificateFile: 'client/ssl/mldsa65-1.crt',
  SSLVerifyMode: OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
}

DRb.start_service(nil, nil, config)

timeserver = DRbObject.new_with_uri(SERVER_URI)
puts "client: #{timeserver.current_time}"

# Print server's SSL socket info
timeserver.print_ssl_socket_info

# Print client's SSL socket info
DRb::DRbConn.open(SERVER_URI) do |conn|
  ssl = conn.instance_variable_get(:@protocol).stream
  puts "client: Group: #{ssl.group}"
  puts "client: Signature Algorithm: #{ssl.sigalg}"
  puts "client: Peer Signature Algorithm: #{ssl.peer_sigalg}"
  [true, nil]
end
