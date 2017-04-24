# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=void kernel
do.devicecheck=1
do.modules=1
do.cleanup=1
do.cleanuponabort=0
device.name1=t03g
device.name2=n7100
device.name3=GT-N7100
device.name4=
device.name5=
} # end properties

# shell variables
block=/dev/block/platform/dw_mmc/by-name/BOOT;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk
chmod 644 $ramdisk/sbin/media_profiles.xml


## AnyKernel install
dump_boot;

# begin ramdisk changes

# begin system changes
mount -o remount,rw /system

# check if this version need kernel modules
mod=/tmp/anykernel/modules
if [ -z $(find "${mod}" -name "*.ko" 1>/dev/null 2>&1) ]; then
  sed -i 's/do.modules=1/do.modules=0/g' /tmp/anykernel/anykernel.sh # disable modules injection
fi

# f2fs support
sed -i '/f2fs/d' fstab.smdk4x12
insert_line fstab.smdk4x12 "thereisnt" "before" "/cache              ext4" "/dev/block/mmcblk0p12    /cache              f2fs      noatime,nosuid,nodev,inline_xattr,inline_data,background_gc=on  wait"
insert_line fstab.smdk4x12 "thereisnt" "before" "/preload            ext4" "/dev/block/mmcblk0p14    /preload            f2fs      noatime,nosuid,nodev,inline_xattr,inline_data,background_gc=on  wait"
insert_line fstab.smdk4x12 "thereisnt" "before" "/data               ext4" "/dev/block/mmcblk0p16    /data               f2fs      noatime,nosuid,nodev,inline_xattr,inline_data,background_gc=on  wait,check,encryptable=footer"

# init.smdk4x12.rc
remove_section init.smdk4x12.rc "on early-init" "noop"
remove_section init.smdk4x12.rc "on charger" "powersave"
remove_section init.smdk4x12.rc "on property:sys.boot_completed=1" "row"
remove_section init.smdk4x12.rc "# Powersave" "performance"
remove_line init.smdk4x12.rc "write /sys/class/mdnie/mdnie/scenario 0"
remove_line init.smdk4x12.rc "write /sys/class/mdnie/mdnie/mode 0"

# remove older modules
rm -rf lib/modules
rm -rf /system/lib/modules
mkdir -p /system/lib/modules

# remove power hal
rm -rf /system/lib/hw/power.*.so

# synapse support
append_file init.smdk4x12.rc "/sbin/uci" synapse

# end system changes
mount -o remount,ro /system

# end ramdisk changes

write_boot;

## end install

