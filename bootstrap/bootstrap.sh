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


# Copy data to the target machine
function sync() {
    # $1 = user, $2 = source, $3 = destination
    rsync -av --mkpath --filter=':- .gitignore' -e "ssh -oControlMaster=no -l $1 -oport=${ssh_port}" "$2" "$1@${target_destination}:${nix_src_path}"
}

# Usage help function
function help_and_exit() {
    echo
    echo "Remotely bootstraps new host from this env-config"
    echo
    echo "USAGE: $0 -n <target_hostname> -d <target_destination> [OPTIONS]"
    echo
    echo "ARGS:"
    echo "  -n <target_hostname>                specify target_hostname of the host to deploy the config on."
    echo "  -d <target_destination>             specify ip or domain for the target host."
    echo "  -k <ssh_key>                        specify the full path to the ssh_key for remote access"
    echo "                                      to the target host."
    echo "                                      Example: -k /home/user/.ssh/my_ssh_key"
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
        -k)
            shift
            ssh_key=$1
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
generated_hardware_config=0
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

    # Nixos-anywhere installation

    # If you already have hardware config in the host flake, this is not needed
    if no_or_yes "Generate a new hardware config for this host? Yes if your env-config doesn't have an entry for this host."; then
        green "Generating hardware-configuration.nix on $target_hostname and adding it to the local env-config."
        "${ssh_root_cmd[@]}" "nixos-generate-config --no-filesystems --root /mnt"
        "${scp_cmd[@]}" root@"$target_destination":/mnt/etc/nixos/hardware-configuration.nix \
            "${git_root}"/hosts/nixos/"$target_hostname"/hardware-configuration.nix
        generated_hardware_config=1
    fi

    # --extra-files puts the ssh host key we generated onto the target machine
    SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- \
        --ssh-port "$ssh_port" \
        --post-kexec-ssh-port "$ssh_port" \
        --extra-files "$temp" \
        --flake .#"$target_hostname" \
        root@"$target_destination"

    if ! yes_or_no "Has your system restarted and are you ready to continue? (no exits)"; then
        exit 0
    fi

    green "Adding $target_destination's ssh host fingerprint to ~/.ssh/known_hosts"
    ssh-keyscan -p "$ssh_port" "$target_destination" | grep -v '^#' >>~/.ssh/known_hosts || true

    cd - >/dev/null
}

function sops_update_age_key() {
    field="$1"
    keyname="$2"
    key="$3"

    if [ ! "$field" == "hosts" ] && [ ! "$field" == "users" ]; then
        red "Invalid field passed to sops_update_age_key. Must be either 'hosts' or 'users'."
        exit 1
    fi

    if [[ -n $(yq ".keys.${field}[] | select(anchor == \"$keyname\")" "${SOPS_FILE}") ]]; then
        green "Updating existing ${keyname} key"
        yq -i "(.keys.${field}[] | select(anchor == \"$keyname\")) = \"$key\"" "$SOPS_FILE"
    else
        green "Adding new ${keyname} key"
        yq -i ".keys.$field += [\"$key\"] | .keys.${field}[-1] anchor = \"$keyname\"" "$SOPS_FILE"
    fi
}

function sops_generate_host_age_key() {
    green "Generating an age key based on the new ssh_host_ed25519_key"

    # Get the SSH key
    target_key=$(ssh-keyscan -p "$ssh_port" -t ssh-ed25519 "$target_destination" 2>&1 | grep ssh-ed25519 | cut -f2- -d" ") || {
        red "Failed to get ssh key. Host down or maybe SSH port now changed?"
        exit 1
    }

    host_age_key=$(echo "$target_key" | ssh-to-age)

    if grep -qv '^age1' <<<"$host_age_key"; then
        red "The result from generated age key does not match the expected format."
        yellow "Result: $host_age_key"
        yellow "Expected format: age10000000000000000000000000000000000000000000000000000000000"
        exit 1
    fi

    green "Updating env-secrets/.sops.yaml"
    sops_update_age_key "hosts" "$target_hostname" "$host_age_key"
}

# Bootstrap
if yes_or_no "Run nixos-anywhere installation?"; then
    nixos_anywhere
fi

updated_age_keys=0
if yes_or_no "Generate host (ssh-based) age key?"; then
    sops_generate_host_age_key
    updated_age_keys=1
fi

# Adds the user and host to the shared.yaml creation rules
function sops_add_shared_creation_rules() {
    u="\"$1_$2\"" # quoted user_host for yaml
    h="\"$2\""    # quoted hostname for yaml

    shared_selector='.creation_rules[] | select(.path_regex == "shared\.yaml$")'
    if [[ -n $(yq "$shared_selector" "${SOPS_FILE}") ]]; then
        echo "BEFORE"
        cat "${SOPS_FILE}"
        if [[ -z $(yq "$shared_selector.key_groups[].age[] | select(alias == $h)" "${SOPS_FILE}") ]]; then
            green "Adding $u and $h to shared.yaml rule"
            # NOTE: Split on purpose to avoid weird file corruption
            yq -i "($shared_selector).key_groups[].age += [$u, $h]" "$SOPS_FILE"
            yq -i "($shared_selector).key_groups[].age[-2] alias = $u" "$SOPS_FILE"
            yq -i "($shared_selector).key_groups[].age[-1] alias = $h" "$SOPS_FILE"
        fi
    else
        red "shared.yaml rule not found"
    fi
}

# Adds the user and host to the host.yaml creation rules
function sops_add_host_creation_rules() {
    host="$2"                     # hostname for selector
    h="\"$2\""                    # quoted hostname for yaml
    u="\"$1_$2\""                 # quoted user_host for yaml
    w="\"$(whoami)_$(hostname)\"" # quoted whoami_hostname for yaml
    n="\"$(hostname)\""           # quoted hostname for yaml

    host_selector=".creation_rules[] | select(.path_regex | contains(\"${host}\.yaml\"))"
    if [[ -z $(yq "$host_selector" "${SOPS_FILE}") ]]; then
        green "Adding new host file creation rule"
        yq -i ".creation_rules += {\"path_regex\": \"${host}\\.yaml$\", \"key_groups\": [{\"age\": [$u, $h]}]}" "$SOPS_FILE"
        # Add aliases one by one
        yq -i "($host_selector).key_groups[].age[0] alias = $u" "$SOPS_FILE"
        yq -i "($host_selector).key_groups[].age[1] alias = $h" "$SOPS_FILE"
        yq -i "($host_selector).key_groups[].age[2] alias = $w" "$SOPS_FILE"
        yq -i "($host_selector).key_groups[].age[3] alias = $n" "$SOPS_FILE"
    fi
}

# Adds the user and host to the shared.yaml and host.yaml creation rules
function sops_add_creation_rules() {
    user="$1"
    host="$2"

    sops_add_shared_creation_rules "$user" "$host"
    sops_add_host_creation_rules "$user" "$host"
}

age_secret_key=""
# Generate a user age key, update the .sops.yaml entries, and return the key in age_secret_key
# args: user, hostname
function sops_generate_user_age_key() {
    target_user="$1"
    target_hostname="$2"
    key_name="${target_user}_${target_hostname}"
    green "Age key does not exist. Generating."
    user_age_key=$(age-keygen)
    readarray -t entries <<<"$user_age_key"
    age_secret_key=${entries[2]}
    public_key=$(echo "${entries[1]}" | rg key: | cut -f2 -d: | xargs)
    green "Generated age key for ${key_name}"
    # Place the anchors into .sops.yaml so other commands can reference them
    sops_update_age_key "users" "$key_name" "$public_key"
    sops_add_creation_rules "${target_user}" "${target_hostname}"

    # "return" key so it can be used by caller
    export age_secret_key
}

function sops_setup_user_age_key() {
    target_user="$1"
    target_hostname="$2"

    secret_file="${nix_secrets_dir}/sops/${target_hostname}.yaml"
    config="${nix_secrets_dir}/.sops.yaml"
    # If the secret file doesn't exist, it means we're generating a new user key as well
    if [ ! -f "$secret_file" ]; then
        green "Host secret file does not exist. Creating $secret_file"
        sops_generate_user_age_key "${target_user}" "${target_hostname}"
        mkdir -p "$(dirname "$secret_file")"
        echo "{}" >"$secret_file"
        sops --config "$config" -e "$secret_file" >"$secret_file.enc"
        mv "$secret_file.enc" "$secret_file"
    fi
    if ! sops --config "$config" -d --extract '["keys]["age"]' "$secret_file" >/dev/null 2>&1; then
        if [ -z "$age_secret_key" ]; then
            sops_generate_user_age_key "${target_user}" "${target_hostname}"
        fi
        # shellcheck disable=SC2116,SC2086
        sops --config "$config" --set "$(echo '["keys"]["age"] "'$age_secret_key'"')" "$secret_file"
    else
        green "Age key already exists for ${target_hostname}"
    fi
}

if yes_or_no "Generate user age key?"; then
    # This may end up creating the host.yaml file, so add creation rules in advance
    sops_setup_user_age_key "$target_user" "$target_hostname"
    # We need to add the new file before we rekey later
    cd "$nix_secrets_dir"
    git add sops/"${target_hostname}".yaml
    cd - >/dev/null
    updated_age_keys=1
fi

if [[ $updated_age_keys == 1 ]]; then
    # If the age generation commands added previously unseen keys (and associated anchors) we want to add those
    # to creation rules, namely <host>.yaml and shared.yaml
    sops_add_creation_rules "${target_user}" "${target_hostname}"
    # Since we may update the sops.yaml file twice above, only rekey once at the end
    just rekey
    green "Updating flake input to pick up new .sops.yaml"
    nix flake update env-secrets
fi

if yes_or_no "Do you want to copy your full env-config and env-secrets to $target_hostname?"; then
    green "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
    ssh-keyscan -p "$ssh_port" "$target_destination" 2>/dev/null | grep -v '^#' >>~/.ssh/known_hosts || true
    green "Copying full env-config to $target_hostname"
    sync "$target_user" "${git_root}"/../env-config
    green "Copying full env-secrets to $target_hostname"
    sync "$target_user" "${nix_secrets_dir}"

    if yes_or_no "Do you want to rebuild immediately?"; then
        green "Rebuilding env-config on $target_hostname"
        $ssh_cmd "cd ${nix_src_path}env-config && sudo nixos-rebuild --impure --show-trace --flake .#$target_hostname switch"
    fi
else
    echo
    green "NixOS was successfully installed!"
    echo "Post-install config build instructions:"
    echo "To copy nix-config from this machine to the $target_hostname, run the following command"
    echo "just sync $target_user $target_destination"
    echo "To rebuild, sign into $target_hostname and run the following command"
    echo "cd env-config"
    echo "sudo nixos-rebuild --show-trace --flake .#$target_hostname switch"
    echo
fi

if [[ $generated_hardware_config == 1 ]]; then
    if yes_or_no "Do you want to commit and push the generated hardware-configuration.nix for $target_hostname to env-config?"; then
        (pre-commit run --all-files 2>/dev/null || true) &&
        git add "$git_root/hosts/$target_hostname/hardware-configuration.nix" &&
        (git commit -m "feat: hardware-configuration.nix for $target_hostname" || true) &&
        git push
    fi
fi

green "Success!"
