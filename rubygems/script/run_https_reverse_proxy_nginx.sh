#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $(basename "${0}") [-p|--pqc]"
    echo "  -p, --pqc  Enable dual RSA + ML-DSA-65 certificates"
    exit 1
}

PQC=false

while [[ "${#}" -gt 0 ]]; do
    case "${1}" in
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

TOP_DIR="$(dirname "${0}")/.."

if [[ "${PQC}" = true ]]; then
    CONF="etc/nginx-pqc.conf"
else
    CONF="etc/nginx.conf"
fi

echo "TLS proxy (nginx): https://127.0.0.1:18443 -> http://127.0.0.1:18808"
nginx -e stderr -p "${TOP_DIR}/server/nginx" -c "${CONF}"
