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

# Generate ML-DSA-65 self-signed certificate
key = OpenSSL::PKey.generate_key('ML-DSA-65')
cert = OpenSSL::X509::Certificate.new
cert.subject = OpenSSL::X509::Name.new([
  ['C', 'JP'], ['O', 'Foo.DRuby.Org'], ['CN', 'Sample']
])
cert.issuer = cert.subject
cert.serial = 0
cert.not_before = Time.now
cert.not_after = Time.now + 3600
cert.public_key = key
cert.sign(key, nil)

ctx = OpenSSL::SSL::SSLContext.new
ctx.add_certificate(cert, key)
ctx.groups = 'SecP256r1MLKEM768'
ctx.sigalgs = 'mldsa65'
ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE

# The object that handles requests on the server
FRONT_OBJECT = TimeServer.new

DRb.start_service(URI, FRONT_OBJECT, {SSLContext: ctx})

puts "server: Key: #{key.inspect}"
puts "server: Signature algorithm: #{cert.signature_algorithm}"

# Wait for the drb server thread to finish before exiting.
DRb.thread.join
