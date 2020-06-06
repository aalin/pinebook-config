#!/bin/bash

set -e

current_script=`realpath "$0"`
current_path=`dirname "$current_script"`
config_path=~/.config
logind_config_path=/etc/systemd/logind.conf

function error() { echo -e "\e[31m$*\e[0m"; }
function success() { echo -e "\e[32m$*\e[0m"; }
function info() { echo -e "\e[33m$*\e[0m"; }
function warn() { echo -e "\e[34m$*\e[0m"; }

function symlink() {
  local src=$1
  local target=$2

  if [[ -e "$target" ]]; then
    error "${target} already exists"
  else
    info "Symlinking $src -> $target, skipping..."
    ln -s "$src" "$target"
  fi
}

function testPowerKeyDisabled() {
  grep -x "HandlePowerKey=ignore" "$logind_config_path" > /dev/null
}

echo "Installing configuration to $config_path"

mkdir -p "$config_path"

for src in "$current_path"/config/*; do
  target="$config_path/`basename $src`"
  symlink "$src" "$target"
done

echo
echo "Symlinking random things"

symlink "$script_path/bin" ~/bin
symlink "$script_path/Xresources" ~/.Xresources

echo
echo "Disabling power key"

if testPowerKeyDisabled; then
  success "Power key already disabled!"
else
  sudo sed -i "s/^#\(HandlePowerKey=\).*$/\1ignore/" /etc/systemd/logind.conf

  if testPowerKeyDisabled; then
    success "Power key disabled"
  else
    error "Power key not disabled"
  fi
fi

echo
echo "Adding ACPI event handlers"
sudo cp -r acpi/* /etc/acpi

echo
success "Everything is set up!"
