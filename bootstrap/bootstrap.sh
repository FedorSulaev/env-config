#!/usr/bin/env bash
set -euo pipefail

# Helpers library
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# User variables
target_hostname=""
target_destination=""
target_user="isouser"
ssh_port="22"
ssh_key=""

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

# SSH Commands
# Base options shared by ssh/scp
ssh_port_opt=(-o Port="$ssh_port")
ssh_base_opts=(
    -o IdentitiesOnly=yes
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -i "$ssh_key"
)

# Optional: faster repeated connections
ssh_mux_opts=(
    -o ControlMaster=auto
    -o ControlPersist=60
    -o ControlPath="$HOME/.ssh/cm-%r@%h:%p"
)
# If you explicitly want to disable multiplexing, keep: (-o ControlPath=none)

# Only add agent forwarding if required
ssh_agent_opt=() # or: ssh_agent_opt=(-A)  # equals -o ForwardAgent=yes

# Build targets
user_host="${target_user}@${target_destination}"
root_host="root@${target_destination}"

# Final commands as arrays
# "${ssh_cmd[@]}" -- some-remote-command
ssh_cmd=(ssh "${ssh_mux_opts[@]}" "${ssh_base_opts[@]}" "${ssh_agent_opt[@]}" "${ssh_port_opt[@]}" -t "$user_host")
ssh_root_cmd=(ssh "${ssh_mux_opts[@]}" "${ssh_base_opts[@]}" "${ssh_agent_opt[@]}" "${ssh_port_opt[@]}" -t "$root_host")
scp_cmd=(scp -P "$ssh_port" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$ssh_key")

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
