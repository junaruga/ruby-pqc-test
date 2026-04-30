#!/bin/bash

set -eu -o pipefail

TOP_DIR="$(dirname "${0}")/.."

echo "TLS proxy (nginx): https://127.0.0.1:18443 -> http://127.0.0.1:18808"
nginx -e stderr -p "${TOP_DIR}/server/nginx" -c etc/nginx.conf
