#!/bin/sh
#
# Simple script to automate building process (nothing special!)
#
# build.sh -> build/rebuild kernel
# build.sh zip -> create/recreate zip only
# build.sh .config -> build/rebuild kernel using .config

if [ -z "${CONFIG}" ]; then
  CONFIG=n7100-new
fi
if [ -z "${JOBS}" ]; then
  JOBS=4
fi

if [ ! "${1}" = zip ]]; then
  if [ ! "${1}" = .config ]; then
    make "${CONFIG}_defconfig"
  fi
  make -j"${JOBS}"
fi

cp arch/arm/boot/zImage template/zImage
find $(find * -maxdepth 0 | sed '/template/d' ) -name "*.ko" -exec cp {} template/modules \;
cd template
zip -r9 ../"void-kernel-$(cat ../version)-g$(git rev-parse --short HEAD)-${CONFIG}.zip" * -x ".gitignore" "modules/placeholder"
