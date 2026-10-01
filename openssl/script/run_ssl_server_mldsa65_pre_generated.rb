#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

require 'socket'
require 'openssl'

PORT = 8787

server_cert = OpenSSL::X509::Certificate.new(File.read('server/ssl/mldsa65-2.crt'))
server_key = OpenSSL::PKey.read(File.read('server/ssl/mldsa65-2.key'))

ctx = OpenSSL::SSL::SSLContext.new
ctx.add_certificate(server_cert, server_key)
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER

puts "server: Key: #{server_key.inspect}"
puts "server: Signature algorithm: #{server_cert.signature_algorithm}"

tcp_server = TCPServer.new('127.0.0.1', PORT)
tcp_client = tcp_server.accept
ssl = OpenSSL::SSL::SSLSocket.new(tcp_client, ctx)
ssl.accept

puts "server: Group: #{ssl.group}"
puts "server: Signature Algorithm: #{ssl.sigalg}"
puts "server: Peer Signature Algorithm: #{ssl.peer_sigalg}"

ssl.puts Time.now.to_s
ssl.close
tcp_client.close
tcp_server.close
