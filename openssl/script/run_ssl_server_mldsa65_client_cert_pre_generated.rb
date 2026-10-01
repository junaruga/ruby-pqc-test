#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

require 'socket'
require 'openssl'

PORT = 8787

server_cert = OpenSSL::X509::Certificate.new(File.read('server/ssl/mldsa65-2.crt'))
server_key = OpenSSL::PKey.read(File.read('server/ssl/mldsa65-2.key'))

ctx = OpenSSL::SSL::SSLContext.new
ctx.groups = 'X25519MLKEM768'
ctx.add_certificate(server_cert, server_key)
# CA certificate to verify client's certificate (mldsa65-3.crt)
ctx.ca_file = 'client/ssl/mldsa65-1.crt'
# CA certificate(s) sent to the client indicating which certificates the
# server accepts. Helps the client choose which certificate to present.
# Optional when the client only has one certificate (mldsa65-3.crt).
ctx.client_ca = [OpenSSL::X509::Certificate.new(File.read('client/ssl/mldsa65-1.crt'))]
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

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
