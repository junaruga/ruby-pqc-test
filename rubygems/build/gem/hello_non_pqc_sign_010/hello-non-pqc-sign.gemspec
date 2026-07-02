Gem::Specification.new do |s|
  s.name = 'hello-non-pqc-sign'
  s.version = '0.1.0'
  s.summary = 'PQC test'
  s.description = 'A simple gem to test PQC with RSA signed cert'
  s.authors = ['Jun Aruga']
  s.email = ['jaruga@ruby-lang.org']
  s.homepage = 'https://github.com/junaruga/ruby-pqc-test'
  s.files = ['lib/hello-non-pqc-sign.rb']
  s.required_ruby_version = '>= 3.0'
  s.license = 'MIT'
  s.cert_chain = [File.expand_path('../../ssl/gem-public_cert_rsa.pem', __dir__)]
  s.signing_key = File.expand_path('../../ssl/gem-private_key_rsa.pem', __dir__)
end
