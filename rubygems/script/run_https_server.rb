#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'webrick'
require 'webrick/https'
require 'openssl'

TOP_DIR = File.expand_path('..', __dir__)
DOC_ROOT = File.join(TOP_DIR, 'server', 'gem')
SSL_DIR = File.join(TOP_DIR, 'server', 'ssl')

# Filter out false-positive SSL_read errors caused by HTTP clients closing
# connections without sending a TLS close_notify alert.
class FilteredLog < WEBrick::Log
  def error(msg)
    return if msg.to_s.include?('SSL_read: unexpected eof')

    super
  end
end

pqc = false
OptionParser.new do |opts|
  opts.on('-p', '--pqc', 'Enable dual RSA + ML-DSA-65 certificates') do
    pqc = true
  end
end.parse!

rsa_cert = OpenSSL::X509::Certificate.new(File.read(File.join(SSL_DIR, 'rsa-2.crt')))
rsa_key = OpenSSL::PKey.read(File.read(File.join(SSL_DIR, 'rsa-2.key')))

server = WEBrick::HTTPServer.new(
  Port: 18_443,
  BindAddress: '127.0.0.1',
  DocumentRoot: DOC_ROOT,
  SSLEnable: true,
  SSLCertificate: rsa_cert,
  SSLPrivateKey: rsa_key,
  Logger: FilteredLog.new($stderr, WEBrick::Log::DEBUG),
  AccessLog: [
    [File.open('/dev/stderr', 'w'), WEBrick::AccessLog::COMBINED_LOG_FORMAT]
  ]
)

if pqc
  ctx = server.ssl_context
  ctx.cert = ctx.key = ctx.extra_chain_cert = nil
  ctx.sigalgs = 'rsa_pss_rsae_sha256:mldsa65'
  ctx.add_certificate(
    OpenSSL::X509::Certificate.new(File.read(File.join(SSL_DIR, 'mldsa65-2.crt'))),
    OpenSSL::PKey.read(File.read(File.join(SSL_DIR, 'mldsa65-2.key')))
  )
  ctx.add_certificate(rsa_cert, rsa_key)
end

trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }

server.start
