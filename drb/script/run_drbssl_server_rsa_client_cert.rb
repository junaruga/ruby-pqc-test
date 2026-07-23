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

  def print_ssl_socket_info
    # OpenSSL::SSL::SSLSocket object
    ssl = Thread.current['DRb']['client'].stream
    puts "server: Group: #{ssl.group}"
    puts "server: Signature Algorithm: #{ssl.sigalg}"
    puts "server: Peer Signature Algorithm: #{ssl.peer_sigalg}"
  end
end

config = {
  SSLCertificate: OpenSSL::X509::Certificate.new(File.read('server/ssl/rsa-2.crt')),
  SSLPrivateKey: OpenSSL::PKey::RSA.new(File.read('server/ssl/rsa-2.key')),
  SSLCACertificateFile: 'client/ssl/rsa-1.crt',
  SSLClientCA: OpenSSL::X509::Certificate.new(File.read('client/ssl/rsa-1.crt')),
  SSLVerifyMode: OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
}

# The object that handles requests on the server
FRONT_OBJECT = TimeServer.new

DRb.start_service(URI, FRONT_OBJECT, config)

# Inspect the given certificate
server = DRb.primary_server
protocol = server.instance_variable_get(:@protocol)
ssl_config = protocol.instance_variable_get(:@config)
pkey = ssl_config.instance_variable_get(:@pkey)
cert = ssl_config.instance_variable_get(:@cert)

puts "server: Key: #{pkey.inspect}"
puts "server: Signature algorithm: #{cert.signature_algorithm}"

# Wait for the drb server thread to finish before exiting.
DRb.thread.join
