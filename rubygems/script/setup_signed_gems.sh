#!/bin/bash

# Generate gem signing certificates (RSA and ML-DSA-65) and build the
# signed test gems. Requires the forked RubyGems and expect.
set -eux -o pipefail

TOP_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
RUBYGEMS_TOP_DIR="${HOME}/git/ruby/rubygems"
GEM="ruby -I${RUBYGEMS_TOP_DIR}/lib ${RUBYGEMS_TOP_DIR}/exe/gem"
KEY_PASS="abc"

# Clean built signed gems
rm -f "${TOP_DIR}"/build/gem/hello_pqc_sign_*/*.gem
rm -f "${TOP_DIR}"/build/gem/hello_non_pqc_sign_*/*.gem

mkdir -p "${TOP_DIR}/build/ssl"

# Workaround: Use my fork repository
if [ ! -d "${RUBYGEMS_TOP_DIR}" ]; then
    git clone https://github.com/junaruga/rubygems.git \
        -b wip/rubygems-pqc-signed-gem "${RUBYGEMS_TOP_DIR}"
fi
pushd "${RUBYGEMS_TOP_DIR}"
bin/rake setup
popd

# Usage: build_signing_cert ALGORITHM FILE_SUFFIX
build_signing_cert() {
    local algorithm="${1}"
    local suffix="${2}"

    pushd "${RUBYGEMS_TOP_DIR}"
    # Emulate input from tty
    expect -c "
      spawn ${GEM} cert --build jaruga@ruby-lang.org -A ${algorithm}
      expect \"Passphrase for your Private Key:\"
      send \"${KEY_PASS}\r\"
      expect \"Please repeat the passphrase for your Private Key:\"
      send \"${KEY_PASS}\r\"
      expect eof
      "
    mv gem-public_cert.pem "${TOP_DIR}/build/ssl/gem-public_cert_${suffix}.pem"
    mv gem-private_key.pem "${TOP_DIR}/build/ssl/gem-private_key_${suffix}.pem"
    popd
}

# Usage: build_signed_gem GEM_DIR GEMSPEC_FILE
build_signed_gem() {
    local gem_dir="${1}"
    local gemspec="${2}"

    pushd "${TOP_DIR}/build/gem/${gem_dir}"
    # Emulate input from tty
    expect -c "
      spawn ${GEM} build ${gemspec}
      expect \"Enter PEM pass phrase:\"
      send \"${KEY_PASS}\r\"
      expect eof
      "
    popd
}

build_signing_cert RSA rsa
build_signing_cert ML-DSA-65 mldsa

build_signed_gem hello_non_pqc_sign_010 hello-non-pqc-sign.gemspec
build_signed_gem hello_non_pqc_sign_011 hello-non-pqc-sign.gemspec
build_signed_gem hello_pqc_sign_010 hello-pqc-sign.gemspec
build_signed_gem hello_pqc_sign_011 hello-pqc-sign.gemspec

echo "OK"
