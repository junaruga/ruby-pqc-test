#!/bin/bash

# Test use cases on the following page in RSA and ML-DSA cases.
# https://guides.rubygems.org/security/
set -eux -o pipefail

TOP_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
RUBYGEMS_TOP_DIR="${HOME}/git/ruby/rubygems"
GEM="ruby -I${RUBYGEMS_TOP_DIR}/lib ${RUBYGEMS_TOP_DIR}/exe/gem"
KEY_PASS="abc"

# Clean built gems
rm -f "${TOP_DIR}"/build/gem/hello_pqc_sign_*/*.gem
rm -f "${TOP_DIR}"/build/gem/hello_non_pqc_sign_*/*.gem

# Set up gem signing certificates
mkdir -p "${TOP_DIR}/build/ssl"

# Workaround: Use my fork repository
if [ ! -d "${RUBYGEMS_TOP_DIR}" ]; then
    git clone https://github.com/junaruga/rubygems.git \
        -b wip/rubygems-pqc-signed-gem "${RUBYGEMS_TOP_DIR}"
fi
pushd "${RUBYGEMS_TOP_DIR}"
bin/rake setup

# RSA gem signing cert, key
# Emulate input from tty
expect -c "
  spawn ${GEM} cert --build jaruga@ruby-lang.org -A RSA
  expect \"Passphrase for your Private Key:\"
  send \"${KEY_PASS}\r\"
  expect \"Please repeat the passphrase for your Private Key:\"
  send \"${KEY_PASS}\r\"
  expect eof
  "
mv gem-public_cert.pem "${TOP_DIR}/build/ssl/gem-public_cert_rsa.pem"
mv gem-private_key.pem "${TOP_DIR}/build/ssl/gem-private_key_rsa.pem"

# ML-DSA gem signing cert, key
# Emulate input from tty
expect -c "
  spawn ${GEM} cert --build jaruga@ruby-lang.org -A ML-DSA-65
  expect \"Passphrase for your Private Key:\"
  send \"${KEY_PASS}\r\"
  expect \"Please repeat the passphrase for your Private Key:\"
  send \"${KEY_PASS}\r\"
  expect eof
  "
mv gem-public_cert.pem "${TOP_DIR}/build/ssl/gem-public_cert_mldsa.pem"
mv gem-private_key.pem "${TOP_DIR}/build/ssl/gem-private_key_mldsa.pem"
popd

${GEM} cert --list

# Build and install RSA signed gems
pushd "${TOP_DIR}/build/gem/hello_non_pqc_sign_010"
${GEM} cert --add ../../ssl/gem-public_cert_rsa.pem
${GEM} cert --list
# Emulate input from tty
expect -c "
  spawn ${GEM} build hello-non-pqc-sign.gemspec
  expect \"Enter PEM pass phrase:\"
  send \"${KEY_PASS}\r\"
  expect eof
  "
${GEM} install hello-non-pqc-sign-0.1.0.gem -P HighSecurity
${GEM} cert --remove gem-public_cert_rsa.pem
popd

# Build and install ML-DSA signed gems
pushd "${TOP_DIR}/build/gem/hello_pqc_sign_010"
${GEM} cert --add ../../ssl/gem-public_cert_mldsa.pem
${GEM} cert --list
# Emulate input from tty
expect -c "
  spawn ${GEM} build hello-pqc-sign.gemspec
  expect \"Enter PEM pass phrase:\"
  send \"${KEY_PASS}\r\"
  expect eof
  "
${GEM} install hello-pqc-sign-0.1.0.gem -P HighSecurity
${GEM} cert --remove gem-public_cert_mldsa.pem
popd

${GEM} cert --list

echo "OK: All tests passed."
