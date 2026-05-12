#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $(basename "${0}") [-d|--pqc-dual] [-s|--pqc-single]"
    echo "  -d, --pqc-dual     Enable dual RSA + ML-DSA-65 certificates"
    echo "  -s, --pqc-single   Enable PQC single cert mode"
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

TOP_DIR="$(dirname "${0}")/.."

if [[ "${PQC_DUAL}" = true ]]; then
    CONF="etc/nginx-pqc-dual.conf"
elif [[ "${PQC_SINGLE}" = true ]]; then
    CONF="etc/nginx-pqc-single.conf"
else
    CONF="etc/nginx.conf"
fi

if [[ "${PQC_SINGLE}" = true ]]; then
    echo "TLS proxy (nginx, PQC single):" \
        "https://127.0.0.1:18443 -> http://127.0.0.1:18808"
    echo "TLS proxy (nginx, non-PQC single):" \
        "https://127.0.0.1:18444 -> http://127.0.0.1:18808"
else
    echo "TLS proxy (nginx): https://127.0.0.1:18443 -> http://127.0.0.1:18808"
fi
nginx -e stderr -p "${TOP_DIR}/server/nginx" -c "${CONF}"
