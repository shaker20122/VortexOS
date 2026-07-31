name: Build VortexOS ISO

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Build ISO directly from repository
        run: |
          docker run --privileged --rm -v ${{ github.workspace }}:/workspace archlinux:latest bash -c "
            set -euo pipefail

            echo '=== 1. تثبيت أدوات البناء ==='
            pacman-key --init
            pacman-key --populate archlinux
            pacman -Sy --noconfirm archlinux-keyring
            pacman -Syu --noconfirm archiso grub syslinux mtools dosfstools xorriso efibootmgr findutils

            cd /workspace

            echo '=== 2. استبدال المتغيرات في ملفات مشروعك ==='
            # استبدال صريح لجميع الكلمات الدليلية في كل ملفات الإقلاع
            find . -type f \( -name '*.cfg' -o -name '*.conf' -o -name '*.entry' \) -exec sed -i 's/%ARCHISO_LABEL%/VortexOS/g' {} +
            find . -type f \( -name '*.cfg' -o -name '*.conf' -o -name '*.entry' \) -exec sed -i 's/archisosearchuuid=%ARCHISO_UUID%/archisolabel=VortexOS/g' {} +
            find . -type f \( -name '*.cfg' -o -name '*.conf' -o -name '*.entry' \) -exec sed -i 's/archisosearchuuid=[^ ]*/archisolabel=VortexOS/g' {} +
            find . -type f \( -name '*.cfg' -o -name '*.conf' -o -name '*.entry' \) -exec sed -i 's/archisobasedir=%INSTALL_DIR%/archisobasedir=arch/g' {} +

            chmod +x profiledef.sh 2>/dev/null || true

            echo '=== 3. تشغيل البناء  ==='
            mkdir -p /workspace/out
            mkarchiso -v -w /tmp/archiso-tmp -o /workspace/out .
          "

      - name: Upload ISO Artifact
        uses: actions/upload-artifact@v4
        with:
          name: VortexOS-ISO
          path: out/*.iso
