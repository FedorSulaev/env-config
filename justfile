# default recipe to display help information
default:
  @just --list

# rebuild darwin flake for the current host
build-darwin:
  sh -c "darwin-rebuild switch --flake \"$HOME/env-config/nix#$(scutil --get ComputerName)\""
