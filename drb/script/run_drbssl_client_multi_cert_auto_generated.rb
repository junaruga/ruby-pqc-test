#!/usr/bin/env ruby
# frozen_string_literal: true

# Use the modified drb with PQC support from the local repository.
$LOAD_PATH.unshift(File.expand_path('~/git/ruby/drb/lib'))

require 'drb/drb'
require 'drb/ssl'

# The URI to connect to
SERVER_URI = 'drbssl://localhost:8787'

# Client 1: Negotiate with server's ML-DSA-65 cert
puts '--- Client 1: ML-DSA-65 ---'

config1 = {
  SSLSignatureAlgorithms: 'mldsa65',
  SSLVerifyMode: OpenSSL::SSL::VERIFY_NONE
}

DRb.start_service(nil, nil, config1)

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

DRb.stop_service
DRb::DRbConn.stop_pool

# Client 2: Negotiate with server's RSA cert
puts '--- Client 2: RSA ---'

config2 = {
  SSLSignatureAlgorithms: 'rsa_pss_rsae_sha256',
  SSLVerifyMode: OpenSSL::SSL::VERIFY_NONE
}

DRb.start_service(nil, nil, config2)

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

DRb.stop_service
