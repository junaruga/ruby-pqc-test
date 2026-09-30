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

cert_name = OpenSSL::X509::Name.new([
  ['C', 'JP'], ['O', 'Foo.DRuby.Org'], ['CN', 'Sample']
])

# Generate ML-DSA-65 self-signed certificate
mldsa65_key = OpenSSL::PKey.generate_key('ML-DSA-65')
mldsa65_cert = OpenSSL::X509::Certificate.new
mldsa65_cert.subject = cert_name
mldsa65_cert.issuer = cert_name
mldsa65_cert.serial = 0
mldsa65_cert.not_before = Time.now
mldsa65_cert.not_after = Time.now + 3600
mldsa65_cert.public_key = mldsa65_key
mldsa65_cert.sign(mldsa65_key, nil)

# Generate RSA self-signed certificate
rsa_key = OpenSSL::PKey::RSA.new(2048)
rsa_cert = OpenSSL::X509::Certificate.new
rsa_cert.subject = cert_name
rsa_cert.issuer = cert_name
rsa_cert.serial = 1
rsa_cert.not_before = Time.now
rsa_cert.not_after = Time.now + 3600
rsa_cert.public_key = rsa_key
rsa_cert.sign(rsa_key, 'SHA256')

ctx = OpenSSL::SSL::SSLContext.new
ctx.add_certificate(mldsa65_cert, mldsa65_key)
ctx.add_certificate(rsa_cert, rsa_key)
ctx.sigalgs = 'mldsa65:rsa_pss_rsae_sha256'
ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE

# The object that handles requests on the server
FRONT_OBJECT = TimeServer.new

DRb.start_service(URI, FRONT_OBJECT, {SSLContext: ctx})

puts "server: Key: #{mldsa65_key.inspect}"
puts "server: Signature algorithm: #{mldsa65_cert.signature_algorithm}"
puts "server: Key: #{rsa_key.inspect}"
puts "server: Signature algorithm: #{rsa_cert.signature_algorithm}"

# Wait for the drb server thread to finish before exiting.
DRb.thread.join
