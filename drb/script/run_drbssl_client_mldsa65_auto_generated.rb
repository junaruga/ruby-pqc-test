#!/usr/bin/env ruby
# frozen_string_literal: true

# Use the modified drb with PQC support from the local repository.
$LOAD_PATH.unshift(File.expand_path('~/git/ruby/drb/lib'))

require 'drb/drb'
require 'drb/ssl'

# The URI to connect to
SERVER_URI = 'drbssl://localhost:8787'

ctx = OpenSSL::SSL::SSLContext.new
ctx.groups = 'SecP256r1MLKEM768'
ctx.sigalgs = 'mldsa65'
ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE

DRb.start_service(nil, nil, {SSLContext: ctx})

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
