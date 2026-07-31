#!/bin/bash
# profiledef.sh for Vortex OS

iso_name="VortexOS"
iso_label="VortexOS"
iso_publisher="Shaker S_12 <https://github.com/shaker20122>"
iso_application="Vortex OS Live/Installation Media"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.grub')
arch="x86_64"
pacman_conf="pacman.conf"
file_permissions=(
  ["/etc/shadow"]="0:0:0400"
)
