#!/usr/bin/env ruby
# frozen_string_literal: true

require 'socket'
require 'openssl'

HOST = '127.0.0.1'
PORT = 8787

ctx = OpenSSL::SSL::SSLContext.new
ctx.add_certificate(
  OpenSSL::X509::Certificate.new(File.read('client/ssl/mldsa65-3.crt')),
  OpenSSL::PKey.read(File.read('client/ssl/mldsa65-3.key'))
)
ctx.ca_file = 'client/ssl/mldsa65-1.crt'
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

tcp = TCPSocket.new(HOST, PORT)
ssl = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
ssl.connect

puts "client: Group: #{ssl.group}"
puts "client: Signature Algorithm: #{ssl.sigalg}"
puts "client: Peer Signature Algorithm: #{ssl.peer_sigalg}"

puts "client: #{ssl.gets.chomp}"

ssl.close
tcp.close
