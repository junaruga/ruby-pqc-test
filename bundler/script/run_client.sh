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

TOP_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
SSL_DIR="$(cd "${TOP_DIR}/../rubygems/client/ssl" && pwd)"
PORT_HTTPS=18443
PORT_HTTPS_NON_PQC=18444

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

rm -rf "${TOP_DIR}/tmp"
mkdir -p "${TOP_DIR}/tmp"

pushd "${TOP_DIR}/tmp"

if [[ "${PQC_DUAL}" = true ]]; then
    echo "Mode: PQC, non-PQC (dual)"

    echo "=== Test 1: PQC (dual) ML-DSA-65 connection" \
        "to port ${PORT_HTTPS}" \
        "(equivalent to ctx.sigalgs = 'mldsa65') ==="
    # FIXME: The `bundle config set ssl_ca_cert` command doesn't work.
    # https://bundler.io/man/bundle-config.1.html - ssl_ca_cert
    # bundle config set --local ssl_ca_cert "${SSL_DIR}/mldsa65-1.crt"
    export SSL_CERT_FILE="${SSL_DIR}/mldsa65-1.crt"
    export OPENSSL_CONF="${SSL_DIR}/mldsa65-client.cnf"
    bundle config set --local \
        mirror.https://localhost:${PORT_HTTPS_NON_PQC} \
        https://localhost:${PORT_HTTPS}
    bundle config set --local path vendor/bundle
    bundle config list
    cp -p "${TOP_DIR}/client/Gemfile.1" Gemfile
    bundle install
    cp -p "${TOP_DIR}/client/Gemfile.2" Gemfile
    bundle update --all
    bundle list
    bundle info hello-pqc

    popd

    # Reset for second test
    rm -rf "${TOP_DIR}/tmp"
    mkdir -p "${TOP_DIR}/tmp"
    bundle config unset --local \
        mirror.https://localhost:${PORT_HTTPS_NON_PQC}

    pushd "${TOP_DIR}/tmp"

    echo "=== Test 2: PQC (dual) RSA connection" \
        "to port ${PORT_HTTPS}" \
        "(equivalent to ctx.sigalgs = 'rsa_pss_rsae_sha256') ==="
    # FIXME: The `bundle config set ssl_ca_cert` command doesn't work.
    # https://bundler.io/man/bundle-config.1.html - ssl_ca_cert
    # bundle config set --local ssl_ca_cert "${SSL_DIR}/rsa-1.crt"
    export SSL_CERT_FILE="${SSL_DIR}/rsa-1.crt"
    export OPENSSL_CONF="${SSL_DIR}/rsa-client.cnf"
    bundle config set --local \
        mirror.https://localhost:${PORT_HTTPS_NON_PQC} \
        https://localhost:${PORT_HTTPS}
    bundle config set --local path vendor/bundle
    bundle config list
    cp -p "${TOP_DIR}/client/Gemfile.1" Gemfile
    bundle install
    cp -p "${TOP_DIR}/client/Gemfile.2" Gemfile
    bundle update --all
    bundle list
    bundle info hello-pqc

    popd
elif [[ "${PQC_SINGLE}" = true ]]; then
    echo "Mode: PQC (single), non-PQC (single)"

    echo "=== Test 1: PQC (single) ML-DSA-65 connection" \
        "to port ${PORT_HTTPS} ==="
    # FIXME: The `bundle config set ssl_ca_cert` command doesn't work.
    # https://bundler.io/man/bundle-config.1.html - ssl_ca_cert
    # bundle config set --local ssl_ca_cert "${SSL_DIR}/mldsa65-1.crt"
    export SSL_CERT_FILE="${SSL_DIR}/mldsa65-1.crt"
    bundle config set --local \
        mirror.https://localhost:${PORT_HTTPS_NON_PQC} \
        https://localhost:${PORT_HTTPS}
    bundle config set --local path vendor/bundle
    bundle config list
    cp -p "${TOP_DIR}/client/Gemfile.1" Gemfile
    bundle install
    cp -p "${TOP_DIR}/client/Gemfile.2" Gemfile
    bundle update --all
    bundle list
    bundle info hello-pqc

    popd

    # Reset for second test
    rm -rf "${TOP_DIR}/tmp"
    mkdir -p "${TOP_DIR}/tmp"
    bundle config unset --local \
        mirror.https://localhost:${PORT_HTTPS_NON_PQC}

    pushd "${TOP_DIR}/tmp"

    echo "=== Test 2: non-PQC (single) RSA connection" \
        "to port ${PORT_HTTPS_NON_PQC} ==="
    # FIXME: The `bundle config set ssl_ca_cert` command doesn't work.
    # https://bundler.io/man/bundle-config.1.html - ssl_ca_cert
    # bundle config set --local ssl_ca_cert "${SSL_DIR}/rsa-1.crt"
    export SSL_CERT_FILE="${SSL_DIR}/rsa-1.crt"
    bundle config set --local path vendor/bundle
    bundle config list
    cp -p "${TOP_DIR}/client/Gemfile.1" Gemfile
    bundle install
    cp -p "${TOP_DIR}/client/Gemfile.2" Gemfile
    bundle update --all
    bundle list
    bundle info hello-pqc

    popd
else
    echo "Mode: non-PQC"

    # FIXME: The `bundle config set ssl_ca_cert` command doesn't work.
    # https://bundler.io/man/bundle-config.1.html - ssl_ca_cert
    # bundle config set --local ssl_ca_cert "${SSL_DIR}/rsa-1.crt"
    export SSL_CERT_FILE="${SSL_DIR}/rsa-1.crt"
    bundle config set --local \
        mirror.https://localhost:${PORT_HTTPS_NON_PQC} \
        https://localhost:${PORT_HTTPS}
    bundle config set --local path vendor/bundle
    bundle config list
    cp -p "${TOP_DIR}/client/Gemfile.1" Gemfile
    bundle install
    cp -p "${TOP_DIR}/client/Gemfile.2" Gemfile
    bundle update --all
    bundle list
    bundle info hello-pqc

    popd
fi

echo "OK: All tests passed."
