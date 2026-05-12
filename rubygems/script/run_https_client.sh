#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $(basename "${0}") [OPTIONS]"
    echo "  -d, --pqc-dual     PQC dual (ML-DSA-65 + RSA) mode"
    echo "  -s, --pqc-single   PQC single cert mode"
    exit 1
}

PQC_DUAL=false
PQC_SINGLE=false

while [[ "${#}" -gt 0 ]]; do
    case "${1}" in
        -d|--pqc-dual)
            PQC_DUAL=true
            shift
            ;;
        -s|--pqc-single)
            PQC_SINGLE=true
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
PORT_HTTPS=18443
PORT_HTTPS_NON_PQC=18444

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

# Generate gemrc files for controlling client SSL CA certificate, sources and
# gem home.
# https://github.com/ruby/rubygems/blob/92b0305c8bbc830f3cb60a6507f8dbc19e4267f7/lib/rubygems/config_file.rb#L256
generate_gemrc() {
    local gemrc_file="${1}"
    local ssl_ca_cert="${2}"
    local source_url="${3}"

    cat > "${gemrc_file}" << EOF
:ssl_ca_cert: ${ssl_ca_cert}
:sources:
- ${source_url}
:gemhome: ${TEST_GEM_HOME}
EOF
}

GEMRC_MLDSA65="${TOP_DIR}/client/gemrc_mldsa65"
GEMRC_RSA="${TOP_DIR}/client/gemrc_rsa"
GEMRC_RSA_SINGLE="${TOP_DIR}/client/gemrc_rsa_single"

generate_gemrc "${GEMRC_MLDSA65}" "${SSL_DIR}/mldsa65-1.crt" \
    "https://localhost:${PORT_HTTPS}/"
generate_gemrc "${GEMRC_RSA}" "${SSL_DIR}/rsa-1.crt" \
    "https://localhost:${PORT_HTTPS}/"
generate_gemrc "${GEMRC_RSA_SINGLE}" "${SSL_DIR}/rsa-1.crt" \
    "https://localhost:${PORT_HTTPS_NON_PQC}/"

GEMRC="${GEMRC_RSA}" \
    gem env gemhome

# OPENSSL_CONF: Specify the signature algorithms for the connection
# See <https://docs.openssl.org/master/man7/openssl-env/> for details.
# GEMRC: Set the gemrc file for the client SSL CA certificate
# See <https://docs.ruby-lang.org/en/master/Gem/ConfigFile.html> for details.
if [[ "${PQC_DUAL}" = true ]]; then
    echo "Mode: PQC, non-PQC (dual)"

    echo "=== Test 1: ML-DSA-65 connection to port ${PORT_HTTPS}" \
        "(equivalent to ctx.sigalgs = 'mldsa65') ==="
    OPENSSL_CONF="${SSL_DIR}/mldsa65-client.cnf" \
        GEMRC="${GEMRC_MLDSA65}" \
        gem install -v 0.1.0 hello-pqc
    OPENSSL_CONF="${SSL_DIR}/mldsa65-client.cnf" \
        GEMRC="${GEMRC_MLDSA65}" \
        gem update hello-pqc
    GEMRC="${GEMRC_MLDSA65}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_MLDSA65}" \
        gem info hello-pqc

    # Reset gem home for second test
    rm -rf "${TEST_GEM_HOME}"
    mkdir -p "${TEST_GEM_HOME}"

    echo "=== Test 2: RSA connection to port ${PORT_HTTPS}" \
        "(equivalent to ctx.sigalgs = 'rsa_pss_rsae_sha256') ==="
    OPENSSL_CONF="${SSL_DIR}/rsa-client.cnf" \
        GEMRC="${GEMRC_RSA}" \
        gem install -v 0.1.0 hello-pqc
    OPENSSL_CONF="${SSL_DIR}/rsa-client.cnf" \
        GEMRC="${GEMRC_RSA}" \
        gem update hello-pqc
    GEMRC="${GEMRC_RSA}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_RSA}" \
        gem info hello-pqc
elif [[ "${PQC_SINGLE}" = true ]]; then
    echo "Mode: PQC (single), non-PQC (single)"

    echo "=== Test 1: PQC (single) ML-DSA-65 connection" \
        "to port ${PORT_HTTPS} ==="
    OPENSSL_CONF="${SSL_DIR}/mldsa65-client.cnf" \
        GEMRC="${GEMRC_MLDSA65}" \
        gem install -v 0.1.0 hello-pqc
    OPENSSL_CONF="${SSL_DIR}/mldsa65-client.cnf" \
        GEMRC="${GEMRC_MLDSA65}" \
        gem update hello-pqc
    GEMRC="${GEMRC_MLDSA65}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_MLDSA65}" \
        gem info hello-pqc

    # Reset gem home for second test
    rm -rf "${TEST_GEM_HOME}"
    mkdir -p "${TEST_GEM_HOME}"

    echo "=== Test 2: non-PQC (single) RSA connection" \
        "to port ${PORT_HTTPS_NON_PQC} ==="
    OPENSSL_CONF="${SSL_DIR}/rsa-client.cnf" \
        GEMRC="${GEMRC_RSA_SINGLE}" \
        gem install -v 0.1.0 hello-pqc
    OPENSSL_CONF="${SSL_DIR}/rsa-client.cnf" \
        GEMRC="${GEMRC_RSA_SINGLE}" \
        gem update hello-pqc
    GEMRC="${GEMRC_RSA_SINGLE}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_RSA_SINGLE}" \
        gem info hello-pqc
else
    echo "Mode: non-PQC"

    GEMRC="${GEMRC_RSA}" \
        gem install -v 0.1.0 hello-pqc
    GEMRC="${GEMRC_RSA}" \
        gem update hello-pqc
    GEMRC="${GEMRC_RSA}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_RSA}" \
        gem info hello-pqc
fi

echo "OK: All tests passed."
