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

            echo '=== 1. تثبيت حزم البناء ==='
            pacman-key --init
            pacman-key --populate archlinux
            pacman -Sy --noconfirm archlinux-keyring
            pacman -Syu --noconfirm archiso grub syslinux mtools dosfstools xorriso efibootmgr rsync

            echo '=== 2. تجهيز مجلد البناء وتجاهل ملفات Workflow ==='
            mkdir -p /tmp/profile
            
            # نسخ ملفات المستودع باستثناء مجلد .github و .git
            rsync -av --exclude='.github' --exclude='.git' /workspace/ /tmp/profile/

            # دمج مجلد VortexOS إذا كان موجوداً
            if [ -d '/workspace/VortexOS' ]; then
              rsync -av /workspace/VortexOS/ /tmp/profile/
            fi

            cd /tmp/profile

            echo '=== 3. تأكيد ضبط Label الإقلاع ==='
            sed -i 's/^iso_label=.*/iso_label="VortexOS"/' profiledef.sh
            chmod +x profiledef.sh 2>/dev/null || true

            echo '=== 4. تشغيل mkarchiso 🚀 ==='
            mkdir -p /workspace/out
            mkarchiso -v -w /tmp/archiso-tmp -o /workspace/out /tmp/profile
          "

      - name: Upload ISO Artifact
        uses: actions/upload-artifact@v4
        with:
          name: VortexOS-ISO
          path: out/*.iso
