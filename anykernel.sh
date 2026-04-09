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
do.check_boot_version=1
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

# Kernel version extraction function from kernel files (raw or compressed)
# Returns only X.X.X-androidYY, discards everything else
extract_kernel_version() {
  local target="$1"
  local ver_str tmpfile

  # Attempt 1: raw (direct strings) - single grep extracts X.X.X-androidYY directly
  ver_str=$(strings "$target" 2>/dev/null | grep -oE 'Linux version [0-9]+\.[0-9]+\.[0-9]+-android[0-9]+' -m1 | cut -d' ' -f3)

  # Attempt 2: compressed kernel → magiskboot decompress then strings
  if [ -z "$ver_str" ]; then
    tmpfile="${target}_ak3decomp"
    magiskboot decompress "$target" "$tmpfile" 2>/dev/null
    if [ -f "$tmpfile" ]; then
      ver_str=$(strings "$tmpfile" 2>/dev/null | grep -oE 'Linux version [0-9]+\.[0-9]+\.[0-9]+-android[0-9]+' -m1 | cut -d' ' -f3)
      rm -f "$tmpfile"
    fi
  fi

  echo "$ver_str"
}

# Version comparison: returns 0 if a >= b, 1 if a < b
version_ge() {
  if [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]; then
    return 0
  else
    return 1
  fi
}

# Kernel Version Check Function: Image vs. Kernel in Device
# Runs before split_boot: reads device kernel version directly from $BLOCK
do_kernelcheck() {
  ui_print " " "  -> Check kernel version compatibility..."

  # BYPASS: do.check_boot_version=0 in anykernel.sh skips check
  if [ "$(file_getprop anykernel.sh do.check_boot_version)" != 1 ]; then
    ui_print "  -> [BYPASS] do.check_boot_version=0: version check SKIPPED."
    ui_print "  -> [BYPASS] Forced flash. Proceed with caution!"
    return 0
  fi

  local new_ver dev_ver new_kver new_abranch dev_kver dev_abranch

  # Version from Image file (new kernel to flash)
  new_ver=$(extract_kernel_version "$AKHOME/Image")
  if [ -z "$new_ver" ]; then
    abort "  -> ERROR: Unable to read version from Image. Abort."
  fi

  # Version from device boot partition (target slot, direct read via $BLOCK)
  dev_ver=$(extract_kernel_version "$BLOCK")
  if [ -z "$dev_ver" ]; then
    abort "  -> ERROR: Unable to read version from device boot partition. Abort."
  fi

  # Split X.X.X and androidYY
  new_kver=$(echo "$new_ver" | cut -d- -f1)
  new_abranch=$(echo "$new_ver" | cut -d- -f2)
  dev_kver=$(echo "$dev_ver" | cut -d- -f1)
  dev_abranch=$(echo "$dev_ver" | cut -d- -f2)

  ui_print "  -> Image  : $new_ver"
  ui_print "  -> Device : $dev_ver"

  # Check 1: android branch must be exactly equal
  if [ "$new_abranch" != "$dev_abranch" ]; then
    abort "  -> MISMATCH Android branch: Image=$new_abranch | Device=$dev_abranch. Abort."
  fi

  # Check 2: kernel version Image must be >= Device
  if ! version_ge "$new_kver" "$dev_kver"; then
    abort "  -> MISMATCH Kernel version: Image=$new_kver < Device=$dev_kver. Abort."
  fi

  ui_print "  -> Kernel version: COMPATIBLE ($new_ver >= $dev_ver)"
}

# Check: runs before split_boot, reads device kernel version directly from $BLOCK
do_kernelcheck

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
