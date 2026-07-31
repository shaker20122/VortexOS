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
            set -euo pipefail

            echo '=== 1. تهيئة المفاتيح والحزم ==='
            pacman-key --init
            pacman-key --populate archlinux
            pacman -Sy --noconfirm archlinux-keyring
            pacman -Syu --noconfirm archiso grub syslinux mtools dosfstools xorriso efibootmgr sed findutils

            echo '=== 2. تجهيز مجلد البناء ==='
            mkdir -p /tmp/build_profile
            
            # نسخ قالب releng الأساسي
            cp -r /usr/share/archiso/configs/releng/* /tmp/build_profile/

            # دمج ملفاتك فوق القالب
            cp -r /workspace/* /tmp/build_profile/ 2>/dev/null || true
            if [ -d '/workspace/VortexOS' ]; then
              cp -r /workspace/VortexOS/* /tmp/build_profile/ 2>/dev/null || true
            fi

            cd /tmp/build_profile

            echo '=== 3. إصلاح واستبدال مسارات الإقلاع بشكل شامل ==='
            # ضبط iso_label في profiledef.sh
            sed -i 's/^iso_label=.*/iso_label="VortexOS"/' profiledef.sh

            # استبدال كافة التلميحات والمتغيرات في جميع الملفات بدون استثناء امتداد
            find . -type f -exec sed -i 's/%ARCHISO_LABEL%/VortexOS/g' {} +
            find . -type f -exec sed -i 's/archisosearchuuid=%ARCHISO_UUID%/archisolabel=VortexOS/g' {} +
            find . -type f -exec sed -i 's/archisosearchuuid=[^ ]*/archisolabel=VortexOS/g' {} +
            find . -type f -exec sed -i 's/archisobasedir=%INSTALL_DIR%/archisobasedir=arch/g' {} +

            echo '=== 4. تشغيل عملية البناء  ==='
            mkarchiso -v -w /tmp/archiso-tmp -o /workspace/out .
          "

      - name: Upload ISO Artifact
        uses: actions/upload-artifact@v4
        with:
          name: VortexOS-ISO
          path: out/*.iso
