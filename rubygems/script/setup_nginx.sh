#!/bin/bash

set -eux -o pipefail

TOP_DIR="$(dirname "${0}")/.."

# Run the base setup script
"${TOP_DIR}/script/setup.sh"

# Set up nginx directories
rm -rf "${TOP_DIR}/server/nginx"
mkdir -p "${TOP_DIR}/server/nginx/etc"
mkdir -p "${TOP_DIR}/server/nginx/tmp"

# Copy nginx configuration
cp "${TOP_DIR}/build/nginx/etc/nginx.conf" "${TOP_DIR}/server/nginx/etc/"

# Test nginx configuration
nginx -e stderr -t -p "${TOP_DIR}/server/nginx" -c etc/nginx.conf

echo "OK"
