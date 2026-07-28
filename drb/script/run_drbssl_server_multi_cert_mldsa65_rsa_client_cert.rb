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

store = OpenSSL::X509::Store.new
store.add_cert(OpenSSL::X509::Certificate.new(File.read('client/ssl/mldsa65-1.crt')))
store.add_cert(OpenSSL::X509::Certificate.new(File.read('client/ssl/rsa-1.crt')))

config = {
  SSLCertificates: [
    [
      OpenSSL::X509::Certificate.new(File.read('server/ssl/mldsa65-2.crt')),
      OpenSSL::PKey.read(File.read('server/ssl/mldsa65-2.key'))
    ],
    [
      OpenSSL::X509::Certificate.new(File.read('server/ssl/rsa-2.crt')),
      OpenSSL::PKey::RSA.new(File.read('server/ssl/rsa-2.key'))
    ]
  ],
  SSLSignatureAlgorithms: 'mldsa65:rsa_pss_rsae_sha256',
  # CA certificates to verify client's certificate (mldsa65-3.crt or rsa-3.crt)
  SSLCertificateStore: store,
  # CA certificate(s) sent to the client indicating which certificates the
  # server accepts. Helps the client choose which certificate to present.
  SSLClientCA: [
    OpenSSL::X509::Certificate.new(File.read('client/ssl/mldsa65-1.crt')),
    OpenSSL::X509::Certificate.new(File.read('client/ssl/rsa-1.crt'))
  ],
  SSLVerifyMode: OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
}

# The object that handles requests on the server
FRONT_OBJECT = TimeServer.new

DRb.start_service(URI, FRONT_OBJECT, config)

# Inspect the given certificates
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
