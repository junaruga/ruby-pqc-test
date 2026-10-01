#!/usr/bin/env ruby
# frozen_string_literal: true

require 'socket'
require 'openssl'

HOST = '127.0.0.1'
PORT = 8787

ctx = OpenSSL::SSL::SSLContext.new
ctx.ca_file = 'client/ssl/mldsa65-1.crt'
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER

tcp = TCPSocket.new(HOST, PORT)
ssl = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
ssl.connect

puts "client: Group: #{ssl.group}"
puts "client: Signature Algorithm: #{ssl.sigalg}"
puts "client: Peer Signature Algorithm: #{ssl.peer_sigalg}"

puts "client: #{ssl.gets.chomp}"

ssl.close
tcp.close
