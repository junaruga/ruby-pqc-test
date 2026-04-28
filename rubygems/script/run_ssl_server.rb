#!/usr/bin/env ruby
# frozen_string_literal: true

require 'webrick'
require 'webrick/https'
require 'openssl'

TOP_DIR = File.expand_path('..', __dir__)
DOC_ROOT = File.join(TOP_DIR, 'server', 'gem')
CERT_FILE = File.join(TOP_DIR, 'server', 'ssl', 'rsa.crt')
KEY_FILE = File.join(TOP_DIR, 'server', 'ssl', 'rsa.key')

server = WEBrick::HTTPServer.new(
  Port: 8089,
  BindAddress: '127.0.0.1',
  DocumentRoot: DOC_ROOT,
  SSLEnable: true,
  SSLCertificate: OpenSSL::X509::Certificate.new(File.read(CERT_FILE)),
  SSLPrivateKey: OpenSSL::PKey::RSA.new(File.read(KEY_FILE)),
  Logger: WEBrick::Log.new($stderr, WEBrick::Log::DEBUG),
  AccessLog: [
    [File.open('/dev/stderr', 'w'), WEBrick::AccessLog::COMBINED_LOG_FORMAT]
  ]
)

trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }

server.start
