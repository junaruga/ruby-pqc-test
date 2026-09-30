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

mldsa65_cert = OpenSSL::X509::Certificate.new(File.read('server/ssl/mldsa65-2.crt'))
mldsa65_key = OpenSSL::PKey.read(File.read('server/ssl/mldsa65-2.key'))
rsa_cert = OpenSSL::X509::Certificate.new(File.read('server/ssl/rsa-2.crt'))
rsa_key = OpenSSL::PKey::RSA.new(File.read('server/ssl/rsa-2.key'))

mldsa65_ca_cert = OpenSSL::X509::Certificate.new(File.read('client/ssl/mldsa65-1.crt'))
rsa_ca_cert = OpenSSL::X509::Certificate.new(File.read('client/ssl/rsa-1.crt'))

store = OpenSSL::X509::Store.new
store.add_cert(mldsa65_ca_cert)
store.add_cert(rsa_ca_cert)

ctx = OpenSSL::SSL::SSLContext.new
ctx.add_certificate(mldsa65_cert, mldsa65_key)
ctx.add_certificate(rsa_cert, rsa_key)
ctx.sigalgs = 'mldsa65:rsa_pss_rsae_sha256'
ctx.cert_store = store
ctx.client_ca = [mldsa65_ca_cert, rsa_ca_cert]
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

# The object that handles requests on the server
FRONT_OBJECT = TimeServer.new

DRb.start_service(URI, FRONT_OBJECT, {SSLContext: ctx})

puts "server: Key: #{mldsa65_key.inspect}"
puts "server: Signature algorithm: #{mldsa65_cert.signature_algorithm}"
puts "server: Key: #{rsa_key.inspect}"
puts "server: Signature algorithm: #{rsa_cert.signature_algorithm}"

# Wait for the drb server thread to finish before exiting.
DRb.thread.join
