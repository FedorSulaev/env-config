#!/usr/bin/env bash
set -euo pipefail

# Helpers library
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# User variables
target_hostname=""
target_destination=""
target_user="isouser"

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
    echo "USAGE: $0 -n <target_hostname> -d <target_destination> [OPTIONS]"
    echo
    echo "ARGS:"
    echo "  -n <target_hostname>                specify target_hostname of the host to deploy the config on."
    echo "  -d <target_destination>             specify ip or domain for the target host."
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
        -d)
            shift
            target_destination=$1
            ;;
        *)
            red "ERROR: Invalid argument."
            help_and_exit
            ;;
    esac
    shift
done

if [ -z "$target_hostname" ] || [ -z "$target_destination" ]; then
    red "ERROR: -n, -d are required"
    echo
    help_and_exit
fi


# Bootstrap functions
function nixos_anywhere() {
    # Clear the known keys to replace with newly generated
    green "Wiping known_hosts of $target_destination"
    ssh-keygen -R "$target_hostname" || true
    ssh-keygen -R "$target_destination" || true

    green "Installing NixOS on remote host $target_hostname at $target_destination"

    # Generate SSH key
    green "Preparing a new ssh_host_ed25519_key pair for $target_hostname."
    # Create the directory where sshd expects to find the host keys
    install -d -m755 "$temp/etc/ssh"

    # Generate host ssh key pair without a passphrase
    ssh-keygen -t ed25519 -f "$temp/etc/ssh/ssh_host_ed25519_key" -C "$target_user"@"$target_hostname" -N ""

    # Set the correct permissions so sshd will accept the key
    chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

    green "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
    # This will fail if we already know the host, but that's fine
    ssh-keyscan -p "$ssh_port" "$target_destination" | grep -v '^#' >>~/.ssh/known_hosts || true
}

# Bootstrap
if yes_or_no "Run nixos-anywhere installation?"; then
    nixos_anywhere
fi
