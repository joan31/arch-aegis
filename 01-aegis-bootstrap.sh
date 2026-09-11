#!/bin/bash
#
# ARCH AEGIS - SYSTEM BOOTSTRAP
#
# LUKS2 + BTRFS + Secure Boot preparation
#
# Run from the Arch Linux installation environment.
#
# ./01-aegis-bootstrap.sh
#
# By Joan
# https://github.com/joan31/
#

set -Eeuo pipefail

trap 'echo -e "\n[ERROR] Failure on line $LINENO. Installation stopped." >&2' ERR


# ==============================================================================
# VARIABLES
# ==============================================================================

disk="/dev/nvme0n1"

efi_partition="${disk}p1"
luks_partition="${disk}p2"

crypt_name="cryptarch"
crypt_device="/dev/mapper/${crypt_name}"

efi_size="500M"
swap_size="4g"


# ------------------------------------------------------------------------------
# MOUNT OPTIONS
# ------------------------------------------------------------------------------

# Common BTRFS mount options
common_opts="rw,noatime,compress=zstd:3,ssd,discard=async,commit=120"

# Hardened subvolumes
extra_opts="nodev,nosuid,noexec"

# Home and games require executable files
home_opts="nodev,nosuid"

# Virtual machine images
# Compression is intentionally omitted because NOCOW will be enabled.
virt_opts="rw,noatime,nodev,nosuid,noexec,ssd,discard=async,commit=120"

# EFI System Partition
efi_opts="rw,noatime,nodev,nosuid,noexec,fmask=0022,dmask=0022"


# ------------------------------------------------------------------------------
# BTRFS SUBVOLUMES
# ------------------------------------------------------------------------------

subvolumes=(
  "@swap"
  "@snapshots"
  "@efibck"
  "@log"
  "@cache"
  "@tmp"
  "@virt"
  "@home"
  "@srv"
  "@games"
)

declare -A mountpoints=(
  ["@swap"]="/mnt/.swap"
  ["@snapshots"]="/mnt/.snapshots"
  ["@efibck"]="/mnt/.efibackup"
  ["@log"]="/mnt/var/log"
  ["@cache"]="/mnt/var/cache"
  ["@tmp"]="/mnt/var/tmp"
  ["@virt"]="/mnt/var/lib/libvirt/images"
  ["@home"]="/mnt/home"
  ["@srv"]="/mnt/srv"
  ["@games"]="/mnt/opt/games"
)


# ==============================================================================
# FUNCTIONS
# ==============================================================================

pause_step() {
  echo
  read -rp "Press Enter to continue..."
  echo
}


confirm_yes() {
  local answer

  read -rp "$1 [y/N] " answer
  answer=${answer,,}

  [[ "$answer" == "y" || "$answer" == "yes" ]]
}


# ==============================================================================
# PRE-FLIGHT CHECKS
# ==============================================================================

clear

echo "=============================================================="
echo " ARCH AEGIS - SYSTEM BOOTSTRAP"
echo "=============================================================="
echo

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This script must be run as root."
  exit 1
fi

if [[ ! -d /sys/firmware/efi ]]; then
  echo "[ERROR] The Arch Linux installation environment"
  echo "        was not booted in UEFI mode."
  exit 1
fi

if [[ ! -b "$disk" ]]; then
  echo "[ERROR] Disk $disk does not exist."
  exit 1
fi

echo "Target disk:"
echo

lsblk -d -o NAME,SIZE,MODEL "$disk"

echo
echo "WARNING"
echo
echo "The following disk will be used:"
echo
echo "    $disk"
echo
echo "ALL DATA on this disk will be destroyed."
echo

read -rp "Type YES to continue: " confirm_install

if [[ "$confirm_install" != "YES" ]]; then
  echo
  echo "Installation canceled."
  exit 0
fi

pause_step


# ==============================================================================
# STEP 1 - CLEAN DISK
# ==============================================================================

echo "=============================================================="
echo " STEP 1 - CLEAN DISK"
echo "=============================================================="
echo

echo "[1/2] Removing existing GPT and MBR partition structures..."
echo

sgdisk --zap-all "$disk"

echo
echo "[OK] Partition structures removed."


echo
echo "[2/2] Checking for remaining filesystem signatures..."
echo

wipefs "$disk" || true

echo

if confirm_yes "Erase all remaining signatures from $disk?"; then
  echo
  echo "Removing filesystem signatures..."

  wipefs --all "$disk"

  echo
  echo "[OK] Disk signatures removed."
else
  echo
  echo "[SKIP] Disk signature cleanup skipped."
fi


echo
echo "Current disk state:"
echo

lsblk -o NAME,SIZE,TYPE,FSTYPE,PTTYPE,PARTTYPE "$disk"

pause_step


# ==============================================================================
# STEP 2 - CLEAN TPM
# ==============================================================================

echo "=============================================================="
echo " STEP 2 - CLEAN TPM"
echo "=============================================================="
echo

echo "Checking persistent TPM objects..."
echo

handles=$(tpm2_getcap handles-persistent | awk '{print $2}' || true)


if [[ -z "$handles" ]]; then
  echo "[OK] No persistent TPM objects found."
else
  echo "Persistent TPM objects:"
  echo

  printf '%s\n' "$handles"

  echo

  if confirm_yes "Delete all persistent TPM objects?"; then
    echo
    echo "Removing persistent TPM objects..."
    echo

    for handle in $handles; do
      echo "  Removing $handle"

      tpm2_evictcontrol \
        -c "$handle" \
        >/dev/null 2>&1
    done

    echo
    echo "[OK] Persistent TPM objects removed."
  else
    echo
    echo "[SKIP] TPM cleanup skipped."
  fi
fi


echo
echo "Verifying TPM state..."
echo

remaining_persistent=$(tpm2_getcap handles-persistent || true)
remaining_transient=$(tpm2_getcap handles-transient || true)


if [[ -z "$remaining_persistent" ]]; then
  echo "Persistent objects : none"
else
  echo "Persistent objects:"
  echo "$remaining_persistent"
fi


if [[ -z "$remaining_transient" ]]; then
  echo "Transient objects  : none"
else
  echo "Transient objects:"
  echo "$remaining_transient"
fi

pause_step


# ==============================================================================
# STEP 3 - CLEAN EFI BOOT ENTRIES
# ==============================================================================

echo "=============================================================="
echo " STEP 3 - CLEAN EFI BOOT ENTRIES"
echo "=============================================================="
echo

echo "Current EFI boot entries:"
echo

efibootmgr || true

echo
echo "Choose EFI cleanup mode:"
echo
echo "  Enter / all       Remove ALL EFI boot entries (default)"
echo "  none              Keep all EFI boot entries"
echo "  0001 0003 ...     Remove only specified entries"
echo

read -rp "EFI cleanup choice [all]: " efi_cleanup

efi_cleanup=${efi_cleanup:-all}
efi_cleanup=${efi_cleanup,,}


if [[ "$efi_cleanup" == "all" ]]; then
  echo
  echo "Removing all EFI boot entries..."
  echo

  mapfile -t boot_entries < <(
    efibootmgr |
      awk '/^Boot[0-9A-Fa-f]{4}/ { print substr($1, 5, 4) }'
  )

  if [[ ${#boot_entries[@]} -eq 0 ]]; then
    echo "[OK] No EFI boot entries found."
  else
    for bootnum in "${boot_entries[@]}"; do
      echo "  Removing Boot${bootnum^^}"

      efibootmgr \
        -b "$bootnum" \
        -B
    done
  fi

elif [[ "$efi_cleanup" == "none" ]]; then
  echo
  echo "[SKIP] EFI boot entries preserved."

else
  echo
  echo "Removing selected EFI boot entries..."
  echo

  for bootnum in $efi_cleanup; do
    if [[ "$bootnum" =~ ^[0-9a-fA-F]{4}$ ]]; then
      echo "  Removing Boot${bootnum^^}"

      efibootmgr \
        -b "$bootnum" \
        -B
    else
      echo "[WARNING] Invalid EFI entry ignored: $bootnum"
    fi
  done
fi


echo
echo "EFI boot entries after cleanup:"
echo

efibootmgr || true

pause_step


# ==============================================================================
# STEP 4 - UPDATE ARCH KEYRING
# ==============================================================================

echo "=============================================================="
echo " STEP 4 - UPDATE ARCH KEYRING"
echo "=============================================================="
echo

echo "Updating Arch Linux keyring..."
echo

pacman -Sy --noconfirm archlinux-keyring

echo
echo "[OK] Arch Linux keyring updated."

pause_step


# ==============================================================================
# STEP 5 - DISK PARTITIONING
# ==============================================================================

echo "=============================================================="
echo " STEP 5 - DISK PARTITIONING"
echo "=============================================================="
echo

echo "Creating GPT partition table..."
echo

sgdisk \
  --clear \
  --align-end \
  --new=1:0:+${efi_size} \
  --typecode=1:ef00 \
  --change-name=1:"EFI system partition" \
  --new=2:0:0 \
  --typecode=2:8309 \
  --change-name=2:"Linux LUKS" \
  "$disk"


partprobe "$disk"
udevadm settle


echo
echo "[OK] Partitioning completed."

echo
echo "Partition layout:"
echo

lsblk \
  -o NAME,SIZE,TYPE,PARTTYPE,PARTLABEL \
  "$disk"


echo
echo "Partition alignment:"
echo

parted "$disk" align-check optimal 1
parted "$disk" align-check optimal 2

pause_step


# ==============================================================================
# STEP 6 - FILESYSTEM CREATION
# ==============================================================================

echo "=============================================================="
echo " STEP 6 - FILESYSTEM CREATION"
echo "=============================================================="
echo


# ------------------------------------------------------------------------------
# EFI
# ------------------------------------------------------------------------------

echo "Formatting EFI System Partition..."
echo

mkfs.vfat \
  -F 32 \
  -n "SYSTEM" \
  -S 4096 \
  -s 1 \
  "$efi_partition"


echo
echo "[OK] EFI System Partition formatted."

pause_step


# ------------------------------------------------------------------------------
# LUKS
# ------------------------------------------------------------------------------

echo "Creating LUKS2 encrypted container..."
echo

cryptsetup \
  --type luks2 \
  --cipher aes-xts-plain64 \
  --hash sha512 \
  --iter-time 5000 \
  --key-size 512 \
  --pbkdf argon2id \
  --label "Linux LUKS" \
  --sector-size 4096 \
  --use-urandom \
  --verify-passphrase \
  luksFormat "$luks_partition"


echo
echo "[OK] LUKS2 container created."

pause_step


echo "Opening LUKS container..."
echo

cryptsetup \
  --allow-discards \
  --persistent \
  open \
  --type luks2 \
  "$luks_partition" \
  "$crypt_name"


echo
echo "[OK] LUKS container opened:"
echo

ls -l "$crypt_device"

pause_step


# ------------------------------------------------------------------------------
# BTRFS
# ------------------------------------------------------------------------------

echo "Formatting encrypted volume as BTRFS..."
echo

mkfs.btrfs \
  -L "Arch Linux" \
  -s 4096 \
  "$crypt_device"


echo
echo "[OK] BTRFS filesystem created."

echo
echo "Filesystem layout:"
echo

lsblk \
  -o NAME,SIZE,FSTYPE,FSVER,LABEL,PARTLABEL,MOUNTPOINTS \
  "$disk"

pause_step


# ==============================================================================
# STEP 7 - BTRFS SUBVOLUME LAYOUT
# ==============================================================================

echo "=============================================================="
echo " STEP 7 - BTRFS SUBVOLUME LAYOUT"
echo "=============================================================="
echo

echo "Mounting BTRFS top-level temporarily..."
echo

mount \
  -o "$common_opts" \
  "$crypt_device" \
  /mnt


echo "Creating root subvolume:"
echo

btrfs subvolume create /mnt/@


echo
echo "Creating Arch Aegis subvolumes:"
echo

for subvol in "${subvolumes[@]}"; do
  echo "  $subvol"

  btrfs subvolume create "/mnt/$subvol"
done


echo
echo "Created BTRFS subvolumes:"
echo

btrfs subvolume list /mnt

pause_step


echo "Unmounting BTRFS top-level..."

umount /mnt

echo
echo "[OK] BTRFS top-level unmounted."

pause_step


# ==============================================================================
# STEP 8 - MOUNT SUBVOLUMES
# ==============================================================================

echo "=============================================================="
echo " STEP 8 - MOUNT SUBVOLUMES"
echo "=============================================================="
echo


# ------------------------------------------------------------------------------
# ROOT
# ------------------------------------------------------------------------------

echo "Mounting root subvolume @..."
echo

mount \
  -o "$common_opts,subvol=@" \
  "$crypt_device" \
  /mnt


# ------------------------------------------------------------------------------
# MOUNT POINTS
# ------------------------------------------------------------------------------

echo "Creating mount points..."
echo

mkdir -p \
  /mnt/efi \
  /mnt/.swap \
  /mnt/.snapshots \
  /mnt/.efibackup \
  /mnt/var/log \
  /mnt/var/tmp \
  /mnt/var/cache \
  /mnt/var/lib/libvirt/images \
  /mnt/home \
  /mnt/srv \
  /mnt/opt/games


# ------------------------------------------------------------------------------
# EFI
# ------------------------------------------------------------------------------

echo "Mounting EFI System Partition..."
echo

mount \
  -o "$efi_opts" \
  "$efi_partition" \
  /mnt/efi


# ------------------------------------------------------------------------------
# OTHER SUBVOLUMES
# ------------------------------------------------------------------------------

echo "Mounting BTRFS subvolumes..."
echo

for subvol in "${subvolumes[@]}"; do
  mountpoint="${mountpoints[$subvol]}"

  case "$subvol" in
    @home|@games)
      opts="$common_opts,$home_opts"
      ;;

    @virt)
      opts="$virt_opts"
      ;;

    *)
      opts="$common_opts,$extra_opts"
      ;;
  esac

  printf '  %-12s -> %s\n' "$subvol" "$mountpoint"

  mount \
    -o "$opts,subvol=$subvol" \
    "$crypt_device" \
    "$mountpoint"
done


echo
echo "Current mount layout:"
echo

findmnt -R /mnt

pause_step


# ==============================================================================
# STEP 9 - CONFIGURE VM NOCOW
# ==============================================================================

echo "=============================================================="
echo " STEP 9 - CONFIGURE VM NOCOW"
echo "=============================================================="
echo

echo "Disabling Copy-on-Write for virtual machine images..."
echo

chattr +C /mnt/var/lib/libvirt/images


echo "Directory attributes:"
echo

lsattr -d /mnt/var/lib/libvirt/images

pause_step


# ==============================================================================
# STEP 10 - CREATE SWAP FILE
# ==============================================================================

echo "=============================================================="
echo " STEP 10 - CREATE SWAP FILE"
echo "=============================================================="
echo

echo "Creating ${swap_size} BTRFS swap file..."
echo

btrfs filesystem mkswapfile \
  --size "$swap_size" \
  /mnt/.swap/swapfile

chmod 600 /mnt/.swap/swapfile


if [[ ! -f /mnt/.swap/swapfile ]]; then
  echo
  echo "[ERROR] Swap file creation failed."
  exit 1
fi


echo
echo "Swap file:"
echo

ls -lh /mnt/.swap/swapfile

echo
echo "[OK] Swap file created."
echo
echo "The swap file is intentionally NOT enabled yet."
echo "Arch Aegis will configure ephemeral encrypted swap later."

pause_step


# ==============================================================================
# STEP 11 - INSTALL BASE SYSTEM
# ==============================================================================

echo "=============================================================="
echo " STEP 11 - INSTALL BASE SYSTEM"
echo "=============================================================="
echo

echo "Installing Arch Linux base system..."
echo

pacstrap /mnt \
  base \
  base-devel \
  linux \
  linux-headers \
  linux-firmware \
  amd-ucode \
  neovim \
  efibootmgr \
  btrfs-progs \
  sbctl \
  plymouth \
  zram-generator


echo
echo "[OK] Base system installation completed."

echo
echo "Installed kernel:"
echo

ls -lh /mnt/boot/vmlinuz-linux

pause_step


# ==============================================================================
# STEP 12 - GENERATE FSTAB
# ==============================================================================

echo "=============================================================="
echo " STEP 12 - GENERATE FSTAB"
echo "=============================================================="
echo

echo "Generating /etc/fstab using filesystem UUIDs..."
echo

genfstab -U /mnt > /mnt/etc/fstab


echo "[OK] fstab generated."

echo
echo "--------------------------------------------------------------"
echo " /etc/fstab"
echo "--------------------------------------------------------------"
echo

cat /mnt/etc/fstab


echo
echo "Review the generated file manually:"
echo
echo "    vim /mnt/etc/fstab"
echo
echo "Verify:"
echo
echo "    BTRFS entries : 0 0"
echo "    /efi (VFAT)   : 0 2"
echo
echo "Do not use fs_passno 1 for the BTRFS root filesystem."

pause_step


# ==============================================================================
# FINAL SUMMARY
# ==============================================================================

echo "=============================================================="
echo " ARCH AEGIS - BOOTSTRAP SUMMARY"
echo "=============================================================="
echo


# ------------------------------------------------------------------------------
# GPT
# ------------------------------------------------------------------------------

partition_table=$(lsblk -o PTTYPE -nr "$disk" | head -n 1)

if [[ "$partition_table" == "gpt" ]]; then
  echo "[OK] Partition table: GPT"
else
  echo "[WARNING] Partition table: $partition_table"
fi

pause_step


# ------------------------------------------------------------------------------
# PARTITION ALIGNMENT
# ------------------------------------------------------------------------------

echo "Partition alignment:"
echo

part1_align=$(parted "$disk" align-check optimal 1 || true)
part2_align=$(parted "$disk" align-check optimal 2 || true)

echo "EFI partition  : $part1_align"
echo "LUKS partition : $part2_align"


if [[ "$part1_align" == *"aligned"* &&
      "$part2_align" == *"aligned"* ]]; then
  echo
  echo "[OK] Both partitions are optimally aligned."
else
  echo
  echo "[WARNING] One or more partitions may not be optimally aligned."
fi

pause_step


# ------------------------------------------------------------------------------
# PHYSICAL BLOCK SIZE
# ------------------------------------------------------------------------------

physical_block_size=$(
  cat "/sys/block/$(basename "$disk")/queue/physical_block_size"
)

if [[ "$physical_block_size" == "4096" ]]; then
  echo "[OK] NVMe physical block size: 4096 bytes"
else
  echo "[WARNING] NVMe physical block size: ${physical_block_size} bytes"
fi

pause_step


# ------------------------------------------------------------------------------
# PARTITIONS
# ------------------------------------------------------------------------------

echo "Partition layout:"
echo

lsblk \
  -o NAME,SIZE,FSTYPE,FSVER,LABEL,PARTLABEL,MOUNTPOINTS \
  "$disk"

pause_step


# ------------------------------------------------------------------------------
# BTRFS SUBVOLUMES
# ------------------------------------------------------------------------------

echo "BTRFS subvolumes:"
echo

btrfs subvolume list -p /mnt

pause_step


# ------------------------------------------------------------------------------
# MOUNTS
# ------------------------------------------------------------------------------

echo "Mount layout:"
echo

findmnt -R /mnt

pause_step


# ------------------------------------------------------------------------------
# NOCOW
# ------------------------------------------------------------------------------

echo "VM image directory attributes:"
echo

lsattr -d /mnt/var/lib/libvirt/images

pause_step


# ------------------------------------------------------------------------------
# SWAP
# ------------------------------------------------------------------------------

echo "Swap file:"
echo

ls -lh /mnt/.swap/swapfile

pause_step


# ------------------------------------------------------------------------------
# FSTAB
# ------------------------------------------------------------------------------

echo "fstab:"
echo

cat /mnt/etc/fstab

echo
echo "Expected filesystem check values:"
echo
echo "    BTRFS entries : 0 0"
echo "    /efi (VFAT)   : 0 2"

pause_step


# ==============================================================================
# END
# ==============================================================================

echo "=============================================================="
echo " ARCH AEGIS BOOTSTRAP COMPLETE"
echo "=============================================================="
echo
echo "Before continuing:"
echo
echo "    vim /mnt/etc/fstab"
echo
echo "Verify the last two fields:"
echo
echo "    BTRFS entries : 0 0"
echo "    /efi (VFAT)   : 0 2"
echo
echo "Then enter the installed system:"
echo
echo "    arch-chroot /mnt"
echo
