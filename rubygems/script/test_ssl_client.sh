#!/bin/bash

set -eux -o pipefail

TOP_DIR="$(dirname "${0}")/.."
TEST_GEM_HOME="${TOP_DIR}/client/gem_home"
SSL_CERT_FILE="${TOP_DIR}/client/ssl/rsa.crt"

GEM_HOME="${TEST_GEM_HOME}" \
    gem env home
SSL_CERT_FILE="${SSL_CERT_FILE}" \
    GEM_HOME="${TEST_GEM_HOME}" \
    gem install hello-pqc \
    --clear-sources \
    -s https://localhost:8089/ \
    -V
GEM_HOME="${TEST_GEM_HOME}" \
    gem list | grep hello-pqc
GEM_HOME="${TEST_GEM_HOME}" \
    gem info hello-pqc

echo "OK"
