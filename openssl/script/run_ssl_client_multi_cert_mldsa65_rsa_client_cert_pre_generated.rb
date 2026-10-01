#!/usr/bin/env ruby
# frozen_string_literal: true

require 'socket'
require 'openssl'

HOST = '127.0.0.1'
PORT = 8787

# Client 1: Negotiate with server's ML-DSA-65 cert
puts '--- Client 1: ML-DSA-65 ---'

ctx1 = OpenSSL::SSL::SSLContext.new
ctx1.add_certificate(
  OpenSSL::X509::Certificate.new(File.read('client/ssl/mldsa65-3.crt')),
  OpenSSL::PKey.read(File.read('client/ssl/mldsa65-3.key'))
)
ctx1.sigalgs = 'mldsa65'
ctx1.ca_file = 'client/ssl/mldsa65-1.crt'
ctx1.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

tcp1 = TCPSocket.new(HOST, PORT)
ssl1 = OpenSSL::SSL::SSLSocket.new(tcp1, ctx1)
ssl1.connect

puts "client: Group: #{ssl1.group}"
puts "client: Signature Algorithm: #{ssl1.sigalg}"
puts "client: Peer Signature Algorithm: #{ssl1.peer_sigalg}"

puts "client: #{ssl1.gets.chomp}"

ssl1.close
tcp1.close

# Client 2: Negotiate with server's RSA cert
puts '--- Client 2: RSA ---'

ctx2 = OpenSSL::SSL::SSLContext.new
ctx2.add_certificate(
  OpenSSL::X509::Certificate.new(File.read('client/ssl/rsa-3.crt')),
  OpenSSL::PKey::RSA.new(File.read('client/ssl/rsa-3.key'))
)
ctx2.sigalgs = 'rsa_pss_rsae_sha256'
ctx2.ca_file = 'client/ssl/rsa-1.crt'
ctx2.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

tcp2 = TCPSocket.new(HOST, PORT)
ssl2 = OpenSSL::SSL::SSLSocket.new(tcp2, ctx2)
ssl2.connect

puts "client: Group: #{ssl2.group}"
puts "client: Signature Algorithm: #{ssl2.sigalg}"
puts "client: Peer Signature Algorithm: #{ssl2.peer_sigalg}"

puts "client: #{ssl2.gets.chomp}"

ssl2.close
tcp2.close
