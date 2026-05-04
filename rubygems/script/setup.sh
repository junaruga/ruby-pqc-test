#!/bin/bash

set -eux -o pipefail

TOP_DIR="$(dirname "${0}")/.."

# Clean working directories
rm -rf "${TOP_DIR}/build/gem/*/*.gem"
rm -rf "${TOP_DIR}/server"
rm -rf "${TOP_DIR}/client"

# Build with .gemspec files
pushd "${TOP_DIR}/build/gem/hello_pqc"
gem build hello-pqc.gemspec
popd

# Set up server gem directory
mkdir -p "${TOP_DIR}/server/gem/gems"
mkdir -p "${TOP_DIR}/server/gem/cache"
mkdir -p "${TOP_DIR}/server/gem/specifications"
cp -p ${TOP_DIR}/build/gem/*/*.gem "${TOP_DIR}/server/gem/gems"
cp -p ${TOP_DIR}/build/gem/*/*.gem "${TOP_DIR}/server/gem/cache"
cp -p "${TOP_DIR}/build/gem/hello_pqc/hello-pqc.gemspec" \
    "${TOP_DIR}/server/gem/specifications/hello-pqc-0.1.0.gemspec"

gem install rubygems-generate_index
gem generate_index -d server/gem

# Set up client gem home directory
mkdir -p "${TOP_DIR}/client/gem_home"

# Set up SSL certificates
# Naming convention: -1 is the CA, -2 is the server cert (signed by the CA).
# CA uses CN=CA and server uses CN=localhost so OpenSSL can distinguish issuer
# from subject during chain verification.
# The client needs the CA cert (via SSL_CERT_FILE) because gem install uses
# VERIFY_PEER, unlike the ruby/openssl test which uses VERIFY_NONE.
mkdir -p "${TOP_DIR}/build/ssl"
mkdir -p "${TOP_DIR}/server/ssl"
mkdir -p "${TOP_DIR}/client/ssl"

# RSA CA (rsa-1)
openssl req \
    -x509 \
    -newkey rsa:2048 \
    -keyout "${TOP_DIR}/build/ssl/rsa-1.key" \
    -subj /CN=CA \
    -nodes \
    -out "${TOP_DIR}/build/ssl/rsa-1.crt"

# RSA server cert (rsa-2)
openssl req \
    -newkey rsa:2048 \
    -keyout "${TOP_DIR}/build/ssl/rsa-2.key" \
    -subj /CN=localhost \
    -addext "subjectAltName=DNS:localhost" \
    -nodes \
    -out "${TOP_DIR}/build/ssl/rsa-2.csr"

openssl x509 \
    -req \
    -in "${TOP_DIR}/build/ssl/rsa-2.csr" \
    -CA "${TOP_DIR}/build/ssl/rsa-1.crt" \
    -CAkey "${TOP_DIR}/build/ssl/rsa-1.key" \
    -CAcreateserial \
    -copy_extensions copyall \
    -out "${TOP_DIR}/build/ssl/rsa-2.crt"

cp "${TOP_DIR}"/build/ssl/rsa-2.{crt,key} "${TOP_DIR}/server/ssl/"
cp "${TOP_DIR}/build/ssl/rsa-1.crt" "${TOP_DIR}/client/ssl/"

# ML-DSA-65 CA (mldsa65-1)
openssl req \
    -x509 \
    -newkey mldsa65 \
    -keyout "${TOP_DIR}/build/ssl/mldsa65-1.key" \
    -subj /CN=CA \
    -nodes \
    -out "${TOP_DIR}/build/ssl/mldsa65-1.crt"

# ML-DSA-65 server cert (mldsa65-2)
openssl req \
    -newkey mldsa65 \
    -keyout "${TOP_DIR}/build/ssl/mldsa65-2.key" \
    -subj /CN=localhost \
    -addext "subjectAltName=DNS:localhost" \
    -nodes \
    -out "${TOP_DIR}/build/ssl/mldsa65-2.csr"

openssl x509 \
    -req \
    -in "${TOP_DIR}/build/ssl/mldsa65-2.csr" \
    -CA "${TOP_DIR}/build/ssl/mldsa65-1.crt" \
    -CAkey "${TOP_DIR}/build/ssl/mldsa65-1.key" \
    -CAcreateserial \
    -copy_extensions copyall \
    -out "${TOP_DIR}/build/ssl/mldsa65-2.crt"

cp "${TOP_DIR}"/build/ssl/mldsa65-2.{crt,key} "${TOP_DIR}/server/ssl/"
cp "${TOP_DIR}/build/ssl/mldsa65-1.crt" "${TOP_DIR}/client/ssl/"

# OpenSSL config files for controlling client signature algorithms.
# gem install does not expose ctx.sigalgs, so we use OPENSSL_CONF instead.
cat > "${TOP_DIR}/build/ssl/mldsa65-sigalgs.cnf" << 'EOF'
openssl_conf = openssl_init

[openssl_init]
ssl_conf = ssl_sect

[ssl_sect]
system_default = system_default_sect

[system_default_sect]
SignatureAlgorithms = mldsa65
EOF

cat > "${TOP_DIR}/build/ssl/rsa-sigalgs.cnf" << 'EOF'
openssl_conf = openssl_init

[openssl_init]
ssl_conf = ssl_sect

[ssl_sect]
system_default = system_default_sect

[system_default_sect]
SignatureAlgorithms = rsa_pss_rsae_sha256
EOF

cp "${TOP_DIR}"/build/ssl/{mldsa65,rsa}-sigalgs.cnf "${TOP_DIR}/client/ssl/"

# Install gems for RubyGems server
gem install rubygems-server
gem install webrick

echo "OK"
