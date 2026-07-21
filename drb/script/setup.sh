#!/bin/bash

set -eux -o pipefail

TOP_DIR="$(dirname "${0}")/.."

# Clean working directories
rm -rf "${TOP_DIR}/build"
rm -rf "${TOP_DIR}/server"
rm -rf "${TOP_DIR}/client"

# Set up SSL certificates
# The file naming convention: foo-1 is the CA, foo-2 is the server cert (signed
# by the CA).
# CA uses CN=CA and server uses CN=localhost so OpenSSL can distinguish issuer
# from subject during chain verification.
mkdir -p "${TOP_DIR}/build/ssl"
mkdir -p "${TOP_DIR}/server/ssl"
mkdir -p "${TOP_DIR}/client/ssl"

# RSA CA (rsa-1)
openssl req \
    -x509 \
    -newkey rsa:2048 \
    -keyout "${TOP_DIR}/build/ssl/rsa-1.key" \
    -subj /CN=CA \
    -nodes \
    -out "${TOP_DIR}/build/ssl/rsa-1.crt"

# RSA server cert (rsa-2)
openssl req \
    -newkey rsa:2048 \
    -keyout "${TOP_DIR}/build/ssl/rsa-2.key" \
    -subj /CN=localhost \
    -addext "subjectAltName=DNS:localhost" \
    -nodes \
    -out "${TOP_DIR}/build/ssl/rsa-2.csr"

openssl x509 \
    -req \
    -in "${TOP_DIR}/build/ssl/rsa-2.csr" \
    -CA "${TOP_DIR}/build/ssl/rsa-1.crt" \
    -CAkey "${TOP_DIR}/build/ssl/rsa-1.key" \
    -CAcreateserial \
    -copy_extensions copyall \
    -out "${TOP_DIR}/build/ssl/rsa-2.crt"

cp "${TOP_DIR}"/build/ssl/rsa-2.{crt,key} "${TOP_DIR}/server/ssl/"
cp "${TOP_DIR}/build/ssl/rsa-1.crt" "${TOP_DIR}/client/ssl/"

# ML-DSA-65 CA (mldsa65-1)
openssl req \
    -x509 \
    -newkey mldsa65 \
    -keyout "${TOP_DIR}/build/ssl/mldsa65-1.key" \
    -subj /CN=CA \
    -nodes \
    -out "${TOP_DIR}/build/ssl/mldsa65-1.crt"

# ML-DSA-65 server cert (mldsa65-2)
openssl req \
    -newkey mldsa65 \
    -keyout "${TOP_DIR}/build/ssl/mldsa65-2.key" \
    -subj /CN=localhost \
    -addext "subjectAltName=DNS:localhost" \
    -nodes \
    -out "${TOP_DIR}/build/ssl/mldsa65-2.csr"

openssl x509 \
    -req \
    -in "${TOP_DIR}/build/ssl/mldsa65-2.csr" \
    -CA "${TOP_DIR}/build/ssl/mldsa65-1.crt" \
    -CAkey "${TOP_DIR}/build/ssl/mldsa65-1.key" \
    -CAcreateserial \
    -copy_extensions copyall \
    -out "${TOP_DIR}/build/ssl/mldsa65-2.crt"

cp "${TOP_DIR}"/build/ssl/mldsa65-2.{crt,key} "${TOP_DIR}/server/ssl/"
cp "${TOP_DIR}/build/ssl/mldsa65-1.crt" "${TOP_DIR}/client/ssl/"

echo "OK"
