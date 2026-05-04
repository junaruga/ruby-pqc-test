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

GEM_HOME="${TEST_GEM_HOME}" \
    gem env home

if [[ "${PQC}" = true ]]; then
    # Test 1: ML-DSA-65 connection (equivalent to ctx.sigalgs = 'mldsa65')
    OPENSSL_CONF="${SSL_DIR}/mldsa65-sigalgs.cnf" \
        SSL_CERT_FILE="${SSL_DIR}/mldsa65-1.crt" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem install hello-pqc \
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
    OPENSSL_CONF="${SSL_DIR}/rsa-sigalgs.cnf" \
        SSL_CERT_FILE="${SSL_DIR}/rsa-1.crt" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem install hello-pqc \
        --clear-sources \
        -s "https://localhost:${PORT}/" \
        -V
    GEM_HOME="${TEST_GEM_HOME}" \
        gem list | grep hello-pqc
    GEM_HOME="${TEST_GEM_HOME}" \
        gem info hello-pqc
else
    SSL_CERT_FILE="${SSL_DIR}/rsa-1.crt" \
        GEM_HOME="${TEST_GEM_HOME}" \
        gem install hello-pqc \
        --clear-sources \
        -s "https://localhost:${PORT}/" \
        -V
    GEM_HOME="${TEST_GEM_HOME}" \
        gem list | grep hello-pqc
    GEM_HOME="${TEST_GEM_HOME}" \
        gem info hello-pqc
fi

echo "OK"
