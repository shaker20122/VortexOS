#!/usr/bin/env bash
# shellcheck shell=bash disable=SC2034
# profiledef.sh for VortexOS
# Commit this file at the repo ROOT. The workflow's rsync merge step
# copies it into the releng-based profile automatically, overwriting
# releng's own profiledef.sh - no separate "cp" step needed.

iso_name="VortexOS"
iso_label="VortexOS"
iso_publisher="Shaker S_12 <https://github.com/shaker20122>"
iso_application="VortexOS Live/Installation Medium"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.grub')
arch="x86_64"
pacman_conf="pacman.conf"
file_permissions=(
  ["/etc/shadow"]="0:0:0400"
)

# NOTE on iso_label: no spaces, ever. A space here becomes a token
# break on the kernel command line (archisolabel=Vortex OS splits into
# two separate boot params) and produces the exact
# "Failed to mount '' on real root" error this project started with.
