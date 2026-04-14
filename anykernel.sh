### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Wild Kernels by TheWildJames aka Morgan Weedman
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
do.check_boot_version=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

# GKI check
kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> Wild Kernels Supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
split_boot

if [ -f "$SPLITIMG/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi

ui_print " "
ui_print "WildKernels Telegram Channel:"
ui_print "https://t.me/WildKernels"
ui_print " "
ui_print "WildKernels Website:"
ui_print "https://wildkernels.dev"
ui_print " "
ui_print "Wild_KSU GitHub Repository:"
ui_print "https://github.com/WildKernels/Wild_KSU"
ui_print "KernelSU-Next fork focused on customization and root-hiding features!"
ui_print " "
ui_print "GKI_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/GKI_KernelSU_SUSFS"
ui_print "GKI kernels with KernelSU and SUSFS."
ui_print " "
ui_print "OnePlus_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/OnePlus_KernelSU_SUSFS"
ui_print "OnePlus kernels with KernelSU and SUSFS."
ui_print " "
ui_print "Samsung_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/Samsung_KernelSU_SUSFS"
ui_print "Samsung kernels with KernelSU and SUSFS."
ui_print " "
