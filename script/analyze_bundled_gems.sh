#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $(basename "${0}") [-h|--help]"
    echo ""
    echo "Check bundled gems for Ruby OpenSSL usage."
    echo "Clones/updates gem repositories and searches for OpenSSL references."
    echo ""
    echo "Output files are saved to analysis/openssl_usage/bundled_gems/"
    exit 0
}

while [[ "${#}" -gt 0 ]]; do
    case "${1}" in
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: ${1}"
            usage
            ;;
    esac
done

BUNDLED_GEMS_FILE="${HOME}/git/ruby/ruby/gems/bundled_gems"
GIT_BASE_DIR="${HOME}/git"
RUBY_GIT_DIR="${GIT_BASE_DIR}/ruby"
TOP_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
OUTPUT_DIR="${TOP_DIR}/analysis/openssl_usage/bundled_gems"

if [[ ! -f "${BUNDLED_GEMS_FILE}" ]]; then
    echo "Error: bundled_gems file not found: ${BUNDLED_GEMS_FILE}"
    exit 1
fi

rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

clone_or_update_repo() {
    local repo_url="${1}"
    local target_dir="${2}"
    local gem_name="${3}"

    if [[ -d "${target_dir}" ]]; then
        echo "Updating existing repository: ${target_dir}"
        pushd "${target_dir}" > /dev/null

        local current_branch
        current_branch="$(git rev-parse --abbrev-ref HEAD)"

        if [[ "${current_branch}" != "main" ]] \
            && [[ "${current_branch}" != "master" ]]; then
            if git show-ref --verify --quiet refs/heads/main; then
                git checkout main < /dev/null
                current_branch="main"
            elif git show-ref --verify --quiet refs/heads/master; then
                git checkout master < /dev/null
                current_branch="master"
            else
                echo "Warning: Neither main nor master branch exists" \
                    "for ${gem_name}"
            fi
        fi

        git pull origin "${current_branch}" < /dev/null \
            || echo "Warning: Failed to pull ${gem_name}"
        popd > /dev/null
    else
        echo "Cloning repository: ${repo_url} -> ${target_dir}"
        git clone "${repo_url}" "${target_dir}" < /dev/null
    fi
}

analyze_openssl_usage() {
    local target_dir="${1}"
    local gem_name="${2}"

    local files_output="${OUTPUT_DIR}/${gem_name}_files.txt"
    local detail_output="${OUTPUT_DIR}/${gem_name}_detail.txt"

    pushd "${target_dir}" > /dev/null

    echo "Analyzing OpenSSL usage in ${gem_name}..."

    local pattern="require +['\"]openssl['\"]|OpenSSL"

    rg "${pattern}" --type ruby -l 2>/dev/null \
        | sort -u > "${files_output}" || true
    rg "${pattern}" --type ruby 2>/dev/null \
        > "${detail_output}" || true

    local file_count
    file_count="$(wc -l < "${files_output}" | tr -d ' ')"
    echo "  Found ${file_count} file(s) with OpenSSL references"

    popd > /dev/null
}

echo "Reading bundled gems from: ${BUNDLED_GEMS_FILE}"
echo "Output directory: ${OUTPUT_DIR}"
echo ""

while IFS= read -r line <&3; do
    [[ -z "${line}" ]] && continue
    [[ "${line}" =~ ^# ]] && continue

    read -r gem_name _version repo_url _rest <<< "${line}"

    [[ -z "${gem_name}" || -z "${repo_url}" ]] && continue

    echo "=== Processing: ${gem_name} ==="

    case "${repo_url}" in
        */minitest/minitest|*/test-unit/test-unit)
            dir_name="$(basename "${repo_url}")"
            target_dir="${GIT_BASE_DIR}/${dir_name}"
            ;;
        */ruby/*)
            dir_name="$(basename "${repo_url}")"
            target_dir="${RUBY_GIT_DIR}/${dir_name}"
            mkdir -p "${RUBY_GIT_DIR}"
            ;;
        *)
            dir_name="$(basename "${repo_url}")"
            target_dir="${GIT_BASE_DIR}/${dir_name}"
            ;;
    esac

    clone_or_update_repo "${repo_url}" "${target_dir}" "${gem_name}"
    analyze_openssl_usage "${target_dir}" "${gem_name}"

    echo ""
done 3< "${BUNDLED_GEMS_FILE}"

echo "=== Summary ==="
echo "Output files saved to: ${OUTPUT_DIR}"
echo ""
echo "Files with OpenSSL usage:"
for f in "${OUTPUT_DIR}"/*_files.txt; do
    gem_name="$(basename "${f}" _files.txt)"
    count="$(wc -l < "${f}" | tr -d ' ')"
    if [[ "${count}" -gt 0 ]]; then
        echo "  ${gem_name}: ${count} file(s)"
    fi
done

echo ""
echo "Done."
