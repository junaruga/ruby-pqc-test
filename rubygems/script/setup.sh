#!/bin/bash

set -eux -o pipefail

TOP_DIR="$(dirname "${0}")/.."

# Clean working directories
rm -rf "${TOP_DIR}/build/*/*.gem"
rm -rf "${TOP_DIR}/server"
rm -rf "${TOP_DIR}/client"

# Build with .gemspec files
pushd "${TOP_DIR}/build/hello_pqc"
gem build hello-pqc.gemspec
popd

# Set up server gem directory
mkdir -p "${TOP_DIR}/server/gem/gems"
mkdir -p "${TOP_DIR}/server/gem/cache"
mkdir -p "${TOP_DIR}/server/gem/specifications"
cp -p ${TOP_DIR}/build/*/*.gem "${TOP_DIR}/server/gem/gems"
cp -p ${TOP_DIR}/build/*/*.gem "${TOP_DIR}/server/gem/cache"
cp -p "${TOP_DIR}/build/hello_pqc/hello-pqc.gemspec" \
    "${TOP_DIR}/server/gem/specifications/hello-pqc-0.1.0.gemspec"

gem install rubygems-generate_index
gem generate_index -d server/gem

# Set up client gem home directory
mkdir -p "${TOP_DIR}/client/gem_home"

echo "OK"
