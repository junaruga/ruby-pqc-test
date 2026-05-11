#!/bin/bash

set -eux -o pipefail

TOP_DIR="$(dirname "${0}")/.."
TEST_GEM_HOME="${TOP_DIR}/client/gem_home"
GEM_HOME="${TEST_GEM_HOME}" \
    gem env home
GEM_HOME="${TEST_GEM_HOME}" \
    gem install -v 0.1.0 hello-pqc \
    --clear-sources \
    -s http://127.0.0.1:18808/ \
    -V
GEM_HOME="${TEST_GEM_HOME}" \
    gem update hello-pqc \
    --clear-sources \
    -s http://127.0.0.1:18808/ \
    -V
GEM_HOME="${TEST_GEM_HOME}" \
    gem list | grep hello-pqc
GEM_HOME="${TEST_GEM_HOME}" \
    gem info hello-pqc

echo "OK"
