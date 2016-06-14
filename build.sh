#!/bin/sh
#
# Simple script to automate building process (nothing special!)
#
# build.sh -> build/rebuild kernel
# build.sh zip -> create/recreate zip only
# build.sh .config -> build/rebuild kernel using .config

if [[ ! "$1" = "zip" ]]; then
	if [[ ! "$1" = ".config" ]]; then
		make n7100_defconfig; fi
	make -j8
fi

cp arch/arm/boot/zImage template/zImage
find . -name "*.ko" -exec cp {} template/modules \;
cd template
zip -r9 ../"void-kernel-$(cat ../version)-g$(git rev-parse --short HEAD)-n7100.zip" * -x ".gitignore" "modules/placeholder"
