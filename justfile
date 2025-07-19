# default recipe to display help information
default:
  @just --list

# rebuild darwin flake for the current host
build-darwin:
  sudo darwin-rebuild switch --flake "$HOME/env-config#$(scutil --get ComputerName)"

# Build an iso image and create a symlink for qemu usage
iso:
  # Clean up the output
  rm -rf result
  nix build --debug --impure "$HOME/env-config#nixosConfigurations.iso.config.system.build.isoImage" --max-jobs 0 --option builders-use-substitutes true && ln -sf result/iso/*.iso latest.iso
