#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

require 'drb/drb'
require 'drb/ssl'

# The URI for the server to connect to
URI = 'drbssl://localhost:8787'

# A simple time server for testing drbssl.
class TimeServer
  def current_time
    Time.now
  end
end

config = {
  SSLCertName: [['C', 'JP'], ['O', 'Foo.DRuby.Org'], ['CN', 'Sample']],
  SSLVerifyMode: OpenSSL::SSL::VERIFY_NONE
}

# The object that handles requests on the server
FRONT_OBJECT = TimeServer.new

DRb.start_service(URI, FRONT_OBJECT, config)

# Inspect the generated certificate
server = DRb.primary_server
protocol = server.instance_variable_get(:@protocol)
# puts "Protocol: #{protocol.inspect}"
ssl_config = protocol.instance_variable_get(:@config)
# puts "SSL Config: #{ssl_config.inspect}"
pkey = ssl_config.instance_variable_get(:@pkey)
cert = ssl_config.instance_variable_get(:@cert)

puts "Key: #{pkey.inspect}"
# puts "Certificate: #{cert.inspect}"
puts "Signature algorithm: #{cert.signature_algorithm}"

# Wait for the drb server thread to finish before exiting.
DRb.thread.join
