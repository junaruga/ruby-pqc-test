#!/bin/bash

# Test use cases on the following page in RSA and ML-DSA cases.
# https://guides.rubygems.org/security/
set -eux -o pipefail

TOP_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
RUBYGEMS_TOP_DIR="${HOME}/git/ruby/rubygems"
GEM="ruby -I${RUBYGEMS_TOP_DIR}/lib ${RUBYGEMS_TOP_DIR}/exe/gem"

# Build signing certificates and signed gems
"${TOP_DIR}/script/setup_signed_gems.sh"

${GEM} cert --list

# Build and install RSA signed gems
pushd "${TOP_DIR}/build/gem/hello_non_pqc_sign_010"
${GEM} cert --add ../../ssl/gem-public_cert_rsa.pem
${GEM} cert --list
${GEM} install hello-non-pqc-sign-0.1.0.gem -P HighSecurity
${GEM} cert --remove jaruga
popd

# Build and install ML-DSA signed gems
pushd "${TOP_DIR}/build/gem/hello_pqc_sign_010"
${GEM} cert --add ../../ssl/gem-public_cert_mldsa.pem
${GEM} cert --list
${GEM} install hello-pqc-sign-0.1.0.gem -P HighSecurity
${GEM} cert --remove jaruga
popd

${GEM} cert --list

echo "OK: All tests passed."
