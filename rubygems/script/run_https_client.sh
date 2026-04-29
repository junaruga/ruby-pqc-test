#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $(basename "${0}") [-p|--port PORT]"
    echo "  -p, --port PORT  Port number (default: 18443)"
    exit 1
}

PORT=18443

while [[ "${#}" -gt 0 ]]; do
    case "${1}" in
        -p|--port)
            PORT="${2}"
            shift 2
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
SSL_CERT_FILE="${TOP_DIR}/client/ssl/rsa.crt"

GEM_HOME="${TEST_GEM_HOME}" \
    gem env home
SSL_CERT_FILE="${SSL_CERT_FILE}" \
    GEM_HOME="${TEST_GEM_HOME}" \
    gem install hello-pqc \
    --clear-sources \
    -s "https://localhost:${PORT}/" \
    -V
GEM_HOME="${TEST_GEM_HOME}" \
    gem list | grep hello-pqc
GEM_HOME="${TEST_GEM_HOME}" \
    gem info hello-pqc

echo "OK"
