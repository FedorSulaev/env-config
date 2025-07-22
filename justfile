# default recipe to display help information
default:
  @just --list

update:
  nix flake update

# rebuild darwin flake for the current host
build-breezora:
  sudo darwin-rebuild switch --flake "$HOME/env-config#breezora"

# Build an iso image and create a symlink for qemu usage
build-iso:
  # Clean up the output
  rm -rf result
  nix build --debug --impure "$HOME/env-config#nixosConfigurations.iso.config.system.build.isoImage" --max-jobs 0 --option builders-use-substitutes true && ln -sf result/iso/*.iso latest.iso

# Create resources and run qemu vm to test the iso
run-vm-iso:
  qemu-img create -f qcow2 ./iso-vm-disk.qcow2 10G
  qemu-system-x86_64 \
    -m 2048 \
    -smp 1 \
    -boot d \
    -cdrom ./latest.iso \
    -drive file=./iso-vm-disk.qcow2,format=qcow2 \
    -name test-iso \
    -nic user,model=virtio,hostfwd=tcp::10022-:22 \
    -nographic

ssh-vm-iso:
  ssh -p 10022 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null isouser@localhost

cleanup-vm-iso:
  rm -f ./iso-vm-disk.qcow2

# Install the latest iso to a flash drive
install-iso DRIVE: build-iso
  sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={{DRIVE}} bs=4M status=progress oflag=sync

# Copy all the config files to the remote host
sync USER HOST PATH:
  rsync -av --filter=':- .gitignore' -e "ssh -l {{USER}} -oport=22" . {{USER}}@{{HOST}}:{{PATH}}/nix-config

