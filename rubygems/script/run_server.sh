#!/bin/bash

set -eu

PROG_DIR="$(dirname "${0}")"

# Run RubyGems server applying the following patch by `-I ..`.
# https://github.com/rubygems/rubygems-server/pull/14
ruby -I ~/git/rubygems/rubygems-server/lib "${PROG_DIR}/run_server.rb"
