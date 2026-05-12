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

pqc_dual = false
pqc_single = false
OptionParser.new do |opts|
  opts.on('-d', '--pqc-dual', 'Enable dual RSA + ML-DSA-65 certificates') do
    pqc_dual = true
  end
  opts.on('-s', '--pqc-single', 'Enable PQC single cert mode') do
    pqc_single = true
  end
end.parse!

rsa_cert_file = File.join(SSL_DIR, 'rsa-2.crt')
rsa_cert = OpenSSL::X509::Certificate.new(File.read(rsa_cert_file))
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

if pqc_dual
  ctx = server.ssl_context
  ctx.cert = ctx.key = ctx.extra_chain_cert = nil
  ctx.sigalgs = 'rsa_pss_rsae_sha256:mldsa65'
  mldsa65_crt = File.join(SSL_DIR, 'mldsa65-2.crt')
  mldsa65_k = File.join(SSL_DIR, 'mldsa65-2.key')
  ctx.add_certificate(
    OpenSSL::X509::Certificate.new(File.read(mldsa65_crt)),
    OpenSSL::PKey.read(File.read(mldsa65_k))
  )
  ctx.add_certificate(rsa_cert, rsa_key)
end

if pqc_single
  mldsa65_crt_file = File.join(SSL_DIR, 'mldsa65-2.crt')
  mldsa65_key_file = File.join(SSL_DIR, 'mldsa65-2.key')
  mldsa65_cert = OpenSSL::X509::Certificate.new(
    File.read(mldsa65_crt_file)
  )
  mldsa65_key = OpenSSL::PKey.read(
    File.read(mldsa65_key_file)
  )

  pqc_server = server
  pqc_ctx = pqc_server.ssl_context
  pqc_ctx.cert = pqc_ctx.key = pqc_ctx.extra_chain_cert = nil
  pqc_ctx.sigalgs = 'mldsa65'
  pqc_ctx.add_certificate(mldsa65_cert, mldsa65_key)

  non_pqc_server = WEBrick::HTTPServer.new(
    Port: 18_444,
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

  trap('INT') do
    pqc_server.shutdown
    non_pqc_server.shutdown
  end
  trap('TERM') do
    pqc_server.shutdown
    non_pqc_server.shutdown
  end

  Thread.new { non_pqc_server.start }
  pqc_server.start
else
  trap('INT') { server.shutdown }
  trap('TERM') { server.shutdown }

  server.start
end
