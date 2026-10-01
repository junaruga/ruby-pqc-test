#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

require 'socket'
require 'openssl'

PORT = 8787

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
ctx.groups = 'X25519MLKEM768'
ctx.add_certificate(mldsa65_cert, mldsa65_key)
ctx.add_certificate(rsa_cert, rsa_key)
ctx.sigalgs = 'mldsa65:rsa_pss_rsae_sha256'
ctx.cert_store = store
ctx.client_ca = [mldsa65_ca_cert, rsa_ca_cert]
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

puts "server: Key: #{mldsa65_key.inspect}"
puts "server: Signature algorithm: #{mldsa65_cert.signature_algorithm}"
puts "server: Key: #{rsa_key.inspect}"
puts "server: Signature algorithm: #{rsa_cert.signature_algorithm}"

tcp_server = TCPServer.new('127.0.0.1', PORT)

2.times do
  tcp_client = tcp_server.accept
  ssl = OpenSSL::SSL::SSLSocket.new(tcp_client, ctx)
  ssl.accept

  puts "server: Group: #{ssl.group}"
  puts "server: Signature Algorithm: #{ssl.sigalg}"
  puts "server: Peer Signature Algorithm: #{ssl.peer_sigalg}"

  ssl.puts Time.now.to_s
  ssl.close
  tcp_client.close
end

tcp_server.close
