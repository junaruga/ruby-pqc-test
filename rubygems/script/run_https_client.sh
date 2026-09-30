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
RUBYGEMS_TOP_DIR="${HOME}/git/ruby/rubygems"
GEM_SIGNED="ruby -I${RUBYGEMS_TOP_DIR}/lib ${RUBYGEMS_TOP_DIR}/exe/gem"

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

# Install and update one signed gem with the HighSecurity trust policy,
# using RubyGems that supports ML-DSA signed gems.
# Usage: test_signed_gem GEMRC_FILE SIGNING_CERT GEM_NAME [OPENSSL_CONF_FILE]
test_signed_gem() {
    local gemrc="${1}"
    local cert="${2}"
    local name="${3}"
    local openssl_conf="${4:-}"
    local -a envs=()

    if [[ -n "${openssl_conf}" ]]; then
        envs+=("OPENSSL_CONF=${openssl_conf}")
    fi

    rm -rf "${TEST_GEM_HOME}"
    mkdir -p "${TEST_GEM_HOME}"

    ${GEM_SIGNED} cert --add "${cert}"

    env "${envs[@]}" GEMRC="${gemrc}" \
        ${GEM_SIGNED} install -v 0.1.0 "${name}" -P HighSecurity -V
    env "${envs[@]}" GEMRC="${gemrc}" \
        ${GEM_SIGNED} update "${name}" -P HighSecurity -V
    GEMRC="${gemrc}" ${GEM_SIGNED} list | grep "${name}"
    GEMRC="${gemrc}" ${GEM_SIGNED} list "${name}" | grep "0\.1\.1"

    ${GEM_SIGNED} cert --remove jaruga
}

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
        gem install -v 0.1.0 hello-pqc -V
    OPENSSL_CONF="${SSL_DIR}/mldsa65-client.cnf" \
        GEMRC="${GEMRC_MLDSA65}" \
        gem update hello-pqc -V
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
        gem install -v 0.1.0 hello-pqc -V
    OPENSSL_CONF="${SSL_DIR}/rsa-client.cnf" \
        GEMRC="${GEMRC_RSA}" \
        gem update hello-pqc -V
    GEMRC="${GEMRC_RSA}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_RSA}" \
        gem info hello-pqc

    echo "=== Test 3: signed gems over ML-DSA-65 connection ==="
    test_signed_gem "${GEMRC_MLDSA65}" "${SSL_DIR}/gem-public_cert_mldsa.pem" \
        hello-pqc-sign "${SSL_DIR}/mldsa65-client.cnf"
    test_signed_gem "${GEMRC_MLDSA65}" "${SSL_DIR}/gem-public_cert_rsa.pem" \
        hello-non-pqc-sign "${SSL_DIR}/mldsa65-client.cnf"

    echo "=== Test 4: signed gems over RSA connection ==="
    test_signed_gem "${GEMRC_RSA}" "${SSL_DIR}/gem-public_cert_mldsa.pem" \
        hello-pqc-sign "${SSL_DIR}/rsa-client.cnf"
    test_signed_gem "${GEMRC_RSA}" "${SSL_DIR}/gem-public_cert_rsa.pem" \
        hello-non-pqc-sign "${SSL_DIR}/rsa-client.cnf"
elif [[ "${PQC_SINGLE}" = true ]]; then
    echo "Mode: PQC (single), non-PQC (single)"

    echo "=== Test 1: PQC (single) ML-DSA-65 connection" \
        "to port ${PORT_HTTPS} ==="
    GEMRC="${GEMRC_MLDSA65}" \
        gem install -v 0.1.0 hello-pqc -V
    GEMRC="${GEMRC_MLDSA65}" \
        gem update hello-pqc -V
    GEMRC="${GEMRC_MLDSA65}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_MLDSA65}" \
        gem info hello-pqc

    # Reset gem home for second test
    rm -rf "${TEST_GEM_HOME}"
    mkdir -p "${TEST_GEM_HOME}"

    echo "=== Test 2: non-PQC (single) RSA connection" \
        "to port ${PORT_HTTPS_NON_PQC} ==="
    GEMRC="${GEMRC_RSA_SINGLE}" \
        gem install -v 0.1.0 hello-pqc -V
    GEMRC="${GEMRC_RSA_SINGLE}" \
        gem update hello-pqc -V
    GEMRC="${GEMRC_RSA_SINGLE}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_RSA_SINGLE}" \
        gem info hello-pqc

    echo "=== Test 3: signed gems over PQC (single) ML-DSA-65 connection ==="
    test_signed_gem "${GEMRC_MLDSA65}" "${SSL_DIR}/gem-public_cert_mldsa.pem" \
        hello-pqc-sign
    test_signed_gem "${GEMRC_MLDSA65}" "${SSL_DIR}/gem-public_cert_rsa.pem" \
        hello-non-pqc-sign

    echo "=== Test 4: signed gems over non-PQC (single) RSA connection ==="
    test_signed_gem "${GEMRC_RSA_SINGLE}" "${SSL_DIR}/gem-public_cert_mldsa.pem" \
        hello-pqc-sign
    test_signed_gem "${GEMRC_RSA_SINGLE}" "${SSL_DIR}/gem-public_cert_rsa.pem" \
        hello-non-pqc-sign
else
    echo "Mode: non-PQC"

    GEMRC="${GEMRC_RSA}" \
        gem install -v 0.1.0 hello-pqc -V
    GEMRC="${GEMRC_RSA}" \
        gem update hello-pqc -V
    GEMRC="${GEMRC_RSA}" \
        gem list | grep hello-pqc
    GEMRC="${GEMRC_RSA}" \
        gem info hello-pqc

    echo "=== Test: signed gems over RSA connection ==="
    test_signed_gem "${GEMRC_RSA}" "${SSL_DIR}/gem-public_cert_mldsa.pem" \
        hello-pqc-sign
    test_signed_gem "${GEMRC_RSA}" "${SSL_DIR}/gem-public_cert_rsa.pem" \
        hello-non-pqc-sign
fi

echo "OK: All tests passed."
