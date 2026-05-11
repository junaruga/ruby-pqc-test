#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $(basename "${0}") [--port PORT] [-p|--pqc]"
    echo "  --port PORT      Port number (default: 18443)"
    echo "  -p, --pqc        Enable PQC (ML-DSA-65) mode"
    exit 1
}

PORT=18443
PQC=false

while [[ "${#}" -gt 0 ]]; do
    case "${1}" in
        --port)
            PORT="${2}"
            shift 2
            ;;
        -p|--pqc)
            PQC=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: ${1}"
            usage
            ;;
    esac
done

set -x

TOP_DIR="$(dirname "${0}")/.."
TEST_GEM_HOME="${TOP_DIR}/client/gem_home"
SSL_DIR="${TOP_DIR}/client/ssl"

rm -rf "${TEST_GEM_HOME}"
mkdir -p "${TEST_GEM_HOME}"

# Generate OpenSSL config files for controlling client signature algorithms.
generate_openssl_conf() {
    local conf_file="${1}"
    local sigalgs="${2}"

    cat > "${conf_file}" << EOF
openssl_conf = openssl_init

[openssl_init]
ssl_conf = ssl_sect

[ssl_sect]
system_default = system_default_sect

[system_default_sect]
SignatureAlgorithms = ${sigalgs}
EOF
}

generate_openssl_conf "${SSL_DIR}/mldsa65-client.cnf" "mldsa65"
generate_openssl_conf "${SSL_DIR}/rsa-client.cnf" "rsa_pss_rsae_sha256"

# Generate gemrc files for controlling client SSL CA certificate.
# https://github.com/ruby/rubygems/blob/92b0305c8bbc830f3cb60a6507f8dbc19e4267f7/lib/rubygems/config_file.rb#L256
generate_gemrc() {
    local gemrc_file="${1}"
    local ssl_ca_cert="${2}"

    cat > "${gemrc_file}" << EOF
:ssl_ca_cert: ${ssl_ca_cert}
EOF
}

GEMRC_MLDSA65="${TOP_DIR}/client/gemrc_mldsa65"
GEMRC_RSA="${TOP_DIR}/client/gemrc_rsa"

generate_gemrc "${GEMRC_MLDSA65}" "${SSL_DIR}/mldsa65-1.crt"
generate_gemrc "${GEMRC_RSA}" "${SSL_DIR}/rsa-1.crt"

GEM_HOME="${TEST_GEM_HOME}" \
    gem env home

# OPENSSL_CONF: Specify the signature algorithms for the connection
# See <https://docs.openssl.org/master/man7/openssl-env/> for details.
# GEMRC: Set the gemrc file for the client SSL CA certificate
# See <https://docs.ruby-lang.org/en/master/Gem/ConfigFile.html> for details.
if [[ "${PQC}" = true ]]; then
    # Test 1: ML-DSA-65 connection (equivalent to ctx.sigalgs = 'mldsa65')
    echo "Test 1"
    OPENSSL_CONF="${SSL_DIR}/mldsa65-client.cnf" \
        GEMRC="${GEMRC_MLDSA65}" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem install -v 0.1.0 hello-pqc \
        --clear-sources \
        -s "https://localhost:${PORT}/" \
        -V
    OPENSSL_CONF="${SSL_DIR}/mldsa65-client.cnf" \
        GEMRC="${GEMRC_MLDSA65}" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem update hello-pqc \
        --clear-sources \
        -s "https://localhost:${PORT}/" \
        -V
    GEM_HOME="${TEST_GEM_HOME}" \
        gem list | grep hello-pqc
    GEM_HOME="${TEST_GEM_HOME}" \
        gem info hello-pqc

    # Reset gem home for second test
    rm -rf "${TEST_GEM_HOME}"
    mkdir -p "${TEST_GEM_HOME}"

    # Test 2: RSA connection (equivalent to ctx.sigalgs = 'rsa_pss_rsae_sha256')
    echo "Test 2"
    OPENSSL_CONF="${SSL_DIR}/rsa-client.cnf" \
        GEMRC="${GEMRC_RSA}" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem install -v 0.1.0 hello-pqc \
        --clear-sources \
        -s "https://localhost:${PORT}/" \
        -V
    OPENSSL_CONF="${SSL_DIR}/rsa-client.cnf" \
        GEMRC="${GEMRC_RSA}" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem update hello-pqc \
        --clear-sources \
        -s "https://localhost:${PORT}/" \
        -V
    GEM_HOME="${TEST_GEM_HOME}" \
        gem list | grep hello-pqc
    GEM_HOME="${TEST_GEM_HOME}" \
        gem info hello-pqc
else
    GEMRC="${GEMRC_RSA}" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem install -v 0.1.0 hello-pqc \
        --clear-sources \
        -s "https://localhost:${PORT}/" \
        -V
    GEMRC="${GEMRC_RSA}" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem update hello-pqc \
        --clear-sources \
        -s "https://localhost:${PORT}/" \
        -V
    GEM_HOME="${TEST_GEM_HOME}" \
        gem list | grep hello-pqc
    GEM_HOME="${TEST_GEM_HOME}" \
        gem info hello-pqc
fi

echo "OK"
