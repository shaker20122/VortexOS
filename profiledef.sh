name: Build VortexOS ISO

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Build ISO using Arch Linux Docker Container
        run: |
          docker run --privileged --rm -v ${{ github.workspace }}:/workspace archlinux:latest bash -c "
            set -e

            echo '=== 1. تثبيت حزم البناء ==='
            pacman-key --init
            pacman-key --populate archlinux
            pacman -Sy --noconfirm archlinux-keyring
            pacman -Syu --noconfirm archiso grub syslinux mtools dosfstools xorriso efibootmgr findutils

            echo '=== 2. تجهيز مجلد البناء ==='
            mkdir -p /tmp/profile
            cp -r /workspace/* /tmp/profile/ 2>/dev/null || true
            rm -rf /tmp/profile/.github /tmp/profile/.git

            cd /tmp/profile

            echo '=== 3. إصلاح ملفات الإقلاع وتثبيت Label ==='
            find . -type f \( -name '*.cfg' -o -name '*.conf' -o -name '*.entry' \) -exec sed -i 's/%ARCHISO_LABEL%/VortexOS/g' {} +
            find . -type f \( -name '*.cfg' -o -name '*.conf' -o -name '*.entry' \) -exec sed -i 's/archisosearchuuid=%ARCHISO_UUID%/archisolabel=VortexOS/g' {} +
            find . -type f \( -name '*.cfg' -o -name '*.conf' -o -name '*.entry' \) -exec sed -i 's/archisobasedir=%INSTALL_DIR%/archisobasedir=arch/g' {} +

            chmod +x profiledef.sh 2>/dev/null || true

            echo '=== 4. تشغيل mkarchiso 🚀 ==='
            mkdir -p /workspace/out
            mkarchiso -v -w /tmp/archiso-tmp -o /workspace/out .
          "

      - name: Upload ISO Artifact
        uses: actions/upload-artifact@v4
        with:
          name: VortexOS-ISO
          path: out/*.iso
