#!/bin/bash

set -eu -o pipefail

set -x

TOP_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
SSL_DIR="$(cd "${TOP_DIR}/../rubygems/client/ssl" && pwd)"
PORT_HTTPS=18443
PORT_HTTPS_NON_PQC=18444

rm -rf "${TOP_DIR}/tmp"
mkdir -p "${TOP_DIR}/tmp"

echo "Mode: PQC (single), non-PQC (single)"

pushd "${TOP_DIR}/tmp"

echo "=== Test 1: PQC (single) ML-DSA-65 connection" \
    "to port ${PORT_HTTPS} ==="
# FIXME: The `bundle config set ssl_ca_cert` command doesn't work.
# https://bundler.io/man/bundle-config.1.html - ssl_ca_cert
# bundle config set --local ssl_ca_cert "${SSL_DIR}/mldsa65-1.crt"
export SSL_CERT_FILE="${SSL_DIR}/mldsa65-1.crt"
bundle config set --local \
    mirror.https://localhost:${PORT_HTTPS_NON_PQC} \
    https://localhost:${PORT_HTTPS}
bundle config set --local path vendor/bundle
bundle config list
cp -p "${TOP_DIR}/client/Gemfile.1" Gemfile
bundle install
cp -p "${TOP_DIR}/client/Gemfile.2" Gemfile
bundle update --all
bundle list
bundle info hello-pqc

popd

# Reset for second test
rm -rf "${TOP_DIR}/tmp"
mkdir -p "${TOP_DIR}/tmp"
bundle config unset --local \
    mirror.https://localhost:${PORT_HTTPS_NON_PQC}

pushd "${TOP_DIR}/tmp"

echo "=== Test 2: non-PQC (single) RSA connection" \
    "to port ${PORT_HTTPS_NON_PQC} ==="
# FIXME: The `bundle config set ssl_ca_cert` command doesn't work.
# bundle config set --local ssl_ca_cert "${SSL_DIR}/rsa-1.crt"
export SSL_CERT_FILE="${SSL_DIR}/rsa-1.crt"
bundle config set --local path vendor/bundle
bundle config list
cp -p "${TOP_DIR}/client/Gemfile.1" Gemfile
bundle install
cp -p "${TOP_DIR}/client/Gemfile.2" Gemfile
bundle update --all
bundle list
bundle info hello-pqc

popd

echo "OK: All tests passed."
