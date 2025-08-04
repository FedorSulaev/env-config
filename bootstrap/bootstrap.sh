#!/usr/bin/env bash
set -euo pipefail

# Helpers library
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# User variables
target_hostname=""

# Create a temp directory for generated host keys
temp=$(mktemp -d)
echo "Temp directory is: $temp"

# Cleanup temporary directory on exit
function cleanup() {
    rm -rf "$temp"
    echo "Temp directory is cleaned up"
}
trap cleanup exit

# Usage help function
function help_and_exit() {
    echo
    echo "Remotely bootstraps new host from this nix-config"
    echo
    echo "USAGE: $0 -n <target_hostname> [OPTIONS]"
    echo
    echo "ARGS:"
    echo "  -n <target_hostname>                specify target_hostname of the host to deploy the config on."
    echo
    echo "OPTIONS:"
    exit 0
}

# Handle command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n)
            shift
            target_hostname=$1
            ;;
        *)
            red "ERROR: Invalid argument."
            help_and_exit
            ;;
    esac
    shift
done

if [ -z "$target_hostname" ]; then
    red "ERROR: -n is required"
    echo
    help_and_exit
fi
