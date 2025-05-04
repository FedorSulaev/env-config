# default recipe to display help information
default:
  @just --list

# rebuild darwin flake for the current host
build-darwin:
  darwin-rebuild switch --flake "$HOME/env-config#$(scutil --get ComputerName)"
