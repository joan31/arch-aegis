# 🛡️ Arch Aegis — Secure & Resilient Arch Linux Installation Guide : A Modern, Secure & Minimal Arch Linux Installation Guide focused on Security, Reliability, Simplicity and System Recovery

![Linux](https://img.shields.io/badge/OS-Linux-black?style=flat-square&logo=linux&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Distro-Arch-blue?style=flat-square&logo=arch-linux)
![EFI](https://img.shields.io/badge/Firmware-EFI-white?style=flat-square&logo=rocket&logoColor=white)
![UKI](https://img.shields.io/badge/Boot-UKI-purple?style=flat-square&logo=linuxfoundation&logoColor=white)
![LUKS2 + TPM2](https://img.shields.io/badge/Encryption-LUKS2%20%2B%20TPM2-orange?style=flat-square&logo=cryptpad&logoColor=white)
![Secure Boot](https://img.shields.io/badge/Secure%20Boot-Enabled-teal?style=flat-square&logo=socket&logoColor=white)
![BTRFS](https://img.shields.io/badge/Filesystem-BTRFS-deepskyblue?style=flat-square&logo=buffer&logoColor=white)
![Systemd](https://img.shields.io/badge/Init-Systemd-slateblue?style=flat-square&logo=circle&logoColor=white)
![zRam](https://img.shields.io/badge/zRam-Enabled-limegreen?style=flat-square&logo=cashapp&logoColor=white)
![Snapper](https://img.shields.io/badge/Snapper-Enabled-darkslategray?style=flat-square&logo=simpleicons&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square&logo=open-source-initiative)](LICENSE)

**Arch Aegis** is a modern, security-focused Arch Linux installation guide designed for users who value **security, reliability, simplicity and system recovery**.

Built upon the foundations of the original **Arch Fortress** project and refined through the experience gained with **Arch Fortress: Reforged**, this guide represents a more mature and carefully engineered approach to building a **robust, predictable and recoverable Arch Linux system**.

Rather than chasing every available feature, Arch Aegis focuses on a **minimal and coherent system architecture**, combining proven technologies with modern security and recovery mechanisms. It adopts **BTRFS** for its advanced snapshot capabilities and integrates them into a system designed to provide reliable recovery alongside **Unified Kernel Images (UKI)**, **LUKS2 with TPM2**, and **Secure Boot**.

> 🛡️ Built on: **EFI**, **UKI**, **LUKS2 + TPM2**, **Secure Boot**, **BTRFS**, **Systemd init**, **zRAM**, **snapper**

---

## 📚 Table of Contents

- [🎯 Overview](#-overview)
- [⚙️ Features](#️-features)
- [📦 Project Structure](#-project-structure)
- [🗂️ Disk Layout & LVM Architecture](#️-disk-layout--lvm-architecture)
- [🔧 Mount Options Summary](#-mount-options-summary)
- [📖 Manual Installation (Step-by-step)](#-manual-installation-step-by-step)
- [❓ FAQ](#-faq)
- [🛠 Requirements](#-requirements)
- [📜 License](#-license)
- [👤 Author](#-author)

---

## 🎯 Overview

**Arch Aegis** is not a distribution or a preconfigured Arch setup — it's a **step-by-step installation guide** for building a modern, secure and resilient Arch Linux system from scratch.

Built upon the foundations of the original 🏰 **Arch Fortress** project and refined through the experience gained with 🏰 **Arch Fortress: Reforged**, Aegis represents a more mature and carefully engineered approach to building a **clean, predictable and recoverable Arch Linux system**.

Designed around **security, reliability, simplicity and system recovery**, it combines modern security technologies with **BTRFS snapshot capabilities** to provide multiple layers of protection against system and kernel-related failures.

- 🧊 **BTRFS** with a carefully designed subvolume layout and **snapper** for system snapshots and rollback
- 🔐 **LUKS2** full-disk encryption with **TPM2** auto-unlocking and passphrase fallback
- 🚀 **Direct EFI boot** using a signed **Unified Kernel Image (UKI)** — no traditional bootloader required
- 💥 Full **Secure Boot** support
- 🧠 Modern `mkinitcpio` using **systemd init hooks**
- 🧵 **zRAM** enabled for fast compressed in-memory swap
- 💾 Encrypted **swap file** on BTRFS as zRAM fallback
  - Uses a transient encryption key generated at boot from `/dev/urandom`
  - ⚠️ Hibernation is not possible (non-persistent encryption key)
- 🛟 **Fallback UKI** for boot recovery
- 🗄️ **Automatic EFI partition backup** with a rolling history of previous backups
- 🔄 **Layered recovery** combining BTRFS system snapshots, a recovery UKI and EFI backups

---

## ⚙️ Features

### 🔐 Security
- Full `/` system encryption with **LUKS2 + TPM2**
- Fallback passphrase support
- Secure Boot ready with signed kernels
- Boot chain based on **signed Unified Kernel Images**

### 🧊 Filesystem
- **BTRFS** with a carefully designed subvolume layout
- The `@` root subvolume contains the system and is the **only subvolume managed by snapper and included in system snapshots**
- Snapshots of `@` provide a consistent restore point for the system
- Additional subvolumes are deliberately separated from `@` to exclude non-system or independently managed data from snapshots:
  - `@home`
  - `@cache`
  - `@log`
  - `@tmp`
  - `@srv`
  - `@virt`
  - `@games`
  - `@snapshots`
  - `@efibck`
  - `@swap`
- `/var/lib` remains part of `@`, allowing system state and package-related data to be restored consistently
- Dedicated subvolume for the BTRFS swap file
- **zRAM** enabled to provide fast compressed RAM-based swap
- Encrypted **swap file** as a fallback to zRAM

### ⚙️ Boot Process
- **No traditional bootloader** — no GRUB or systemd-boot
- EFI directly loads a **signed Unified Kernel Image (UKI)**
- UKIs are built with `mkinitcpio` and contain:
  - Kernel
  - Initramfs
  - Kernel command line
  - CPU microcode

### 🧠 Init System
- `mkinitcpio` using:
  - `systemd`
  - `sd-vconsole`
  - `sd-encrypt`
- No legacy hooks such as `udev`, `usr`, `resume`, `keymap`, `consolefont`, or `encrypt`
- A modern and streamlined initramfs based on systemd

### 🛟 UKI Recovery
- **Fallback UKI** built with a more generic initramfs for recovery
- Provides a recovery boot option if the normal UKI or the installed kernel fails to boot correctly
- Can be used to boot the system and perform recovery operations when the normal boot path is broken
- Works alongside **BTRFS snapshots** to restore the system to a previous known-good state

### 🗄️ Automatic EFI Partition Backup
- The `/efi` EFI System Partition (ESP) is automatically backed up before relevant system updates
- Backups are stored in `/.efibackup`
- A rolling history of the **3 most recent EFI backups** is maintained
- Provides an additional recovery layer in case of EFI or UKI-related issues

### 🔄 System Recovery
- **BTRFS snapshots of `@`** provide restore points for the complete system
- **Fallback UKI** provides a generic bootable recovery environment
- **EFI backups** allow restoration of previous EFI and UKI states
- The combination of these layers provides a recovery path for failed kernel or system updates
- Non-system data such as `/home`, VM images, games, logs, caches and temporary files remain outside the `@` snapshot scope

---

## 📦 Project Structure

<details>
<summary>📁 <code>arch-aegis/</code> (click to expand)</summary>

```text
arch-aegis/
├── LICENSE
└── README.md
```

</details>

---

## 🗂️ Disk Layout & Subvolume Architecture

> This is the storage layout used by **Arch Aegis**, based on a secure and flexible setup combining LUKS2, BTRFS, and EFI boot with UKI.

### 💽 Partition Table (GPT - `/dev/nvme0n1`)

| Partition        | Type              | FS    | Mount Point | Size | Description                         |
|------------------|-------------------|-------|-------------|------|-------------------------------------|
| `/dev/nvme0n1p1` | EFI System (ef00) | FAT32 | `/efi`      | 500M | EFI System Partition (boot via UKI) |
| `/dev/nvme0n1p2` | Linux LUKS (8309) | LUKS2 | [LUKS]      | ~2TB | Encrypted root volume               |

---

### 🔐 Encrypted Storage

- `/dev/nvme0n1p2` is encrypted using **LUKS2** with **TPM2** auto-unlocking.
- Opened as `/dev/mapper/cryptarch`.
- Inside: **BTRFS** filesystem with multiple subvolumes

---

### 🌳 BTRFS Subvolume Layout

| Subvolumes   | Mount Point               | Description                       |
|--------------|---------------------------|-----------------------------------|
| `@`          | `/`                       | Root system                       |
| `@home`      | `/home`                   | User data                         |
| `@cache`     | `/var/cache`              | System cache                      |
| `@log`       | `/var/log`                | System logs                       |
| `@tmp`       | `/var/tmp`                | Temporary files                   |
| `@srv`       | `/srv`                    | Server data                       |
| `@virt`      | `/var/lib/libvirt/images` | Virtual machines                  |
| `@games`     | `/opt/games`              | Optional game data                |
| `@snapshots` | `/.snapshots`             | Snapper snapshots                 |
| `@efibck`    | `/.efibackup`             | EFI partition backups (automated) |
| `@swap`      | `/.swap`                  | Encrypted swapfile (e.g. 4GB)     |

---

🧠 **Why this layout?**

This architecture is designed to provide:

- 🔒 **Security** through isolated mount points and dedicated mount options.
- 🛟 **Recovery** by keeping the system root in `@`, allowing consistent BTRFS snapshots and system rollback.
- 🛠️ **Maintainability** by separating system data from logs, caches, temporary files and application data.
- 💾 **Efficient snapshots** by excluding frequently changing or non-system data from the `@` snapshot scope.
- 🚀 **Performance** by keeping write-intensive and large data workloads (logs, cache, VMs, games) outside system snapshots.
- 🧩 **Flexibility** by allowing independent subvolumes to be managed, backed up or restored separately without affecting the system root.

---

### 🖼️ Layout Diagram

```
Disk: /dev/nvme0n1 (GPT)
┌──────────────────────────────────────────────────┐
│ Partition Table                                  │
│──────────────────────────────────────────────────│
│ /dev/nvme0n1p1   → EFI System (FAT32, 500M)      │
│                  └── Mounted at /efi             │
│                                                  │
│ /dev/nvme0n1p2   → LUKS2 Encrypted Volume (~2TB) │
│                  └── mapper/cryptarch            │
│                      └── BTRFS filesystem        │
│                          └── Subvolumes          │
└──────────────────────────────────────────────────┘
```

BTRFS Subvolumes (inside /dev/mapper/cryptarch):

```
┌────────────────────────────────────────────────────────────────────────┐
│ @           → /                                      ← Root filesystem │
│ @home       → /home                                                    │
│ @cache      → /var/cache                                               │
│ @log        → /var/log                                                 │
│ @tmp        → /var/tmp                                                 │
│ @srv        → /srv            ← Kept outside the system snapshot scope |
│ @virt       → /var/lib/libvirt/images                                  │
│ @games      → /opt/games                                               │
│ @snapshots  → /.snapshots                                ← For Snapper │
│ @efibck     → /.efibackup                                ← EFI backups │
│ @swap       → /.swap  ← Dedicated subvolume for the encrypted swapfile │
└────────────────────────────────────────────────────────────────────────┘
```

Boot process:

```
[ EFI Firmware ]
    ↓
[ UKI Image (.efi) in /efi ]
    ↓
[ systemd (init) in initramfs ]
    ↓
[ Unlock LUKS via TPM2 ]
    ↓
[ Mount BTRFS subvolumes ]
    ↓
[ Boot into secure, modern Arch Aegis 🔐🛡️ ]
```

---

## 🔧 Mount Options Summary

### 📂 Mount Points and Options

| 📍 Mount Point | 💽 Device | 🗂️ Subvolumes | ⚙️ Mount Options |
|---|---|---|---|
| `/` | `/dev/mapper/cryptarch` | `@` | `rw,noatime,compress=zstd:3,ssd,discard=async` |
| `/efi` | `/dev/nvme0n1p1` | *(N/A)* | `rw,noatime,nodev,nosuid,noexec,fmask=0022,dmask=0022` |
| `/.swap` | `/dev/mapper/cryptarch` | `@swap` | `rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async` |
| `/.snapshots` | `/dev/mapper/cryptarch` | `@snapshots` | `rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async` |
| `/.efibackup` | `/dev/mapper/cryptarch` | `@efibck` | `rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async` |
| `/var/log` | `/dev/mapper/cryptarch` | `@log` | `rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async` |
| `/var/tmp` | `/dev/mapper/cryptarch` | `@tmp` | `rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async` |
| `/var/cache` | `/dev/mapper/cryptarch` | `@cache` | `rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async` |
| `/var/lib/libvirt/images` | `/dev/mapper/cryptarch` | `@virt` | `rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async` |
| `/home` | `/dev/mapper/cryptarch` | `@home` | `rw,noatime,nodev,nosuid,compress=zstd:3,ssd,discard=async` |
| `/srv` | `/dev/mapper/cryptarch` | `@srv` | `rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async` |
| `/opt/games` | `/dev/mapper/cryptarch` | `@games` | `rw,noatime,nodev,nosuid,compress=zstd:3,ssd,discard=async` |

---

### 📖 Mount Options Explanation

| ⚙️ Option | 🔎 Description | 🏷️ Category |
|---|---|---|
| `rw` | Mount as read-write. | 🔧 Default |
| `noatime` | Do not update file access times, reducing unnecessary filesystem I/O and SSD writes. | 🚀 Performance |
| `nodev` | Prevents character/block device files from being interpreted (security hardening). | 🔒 Security |
| `nosuid` | Disable set-user-ID and set-group-ID bits (security hardening). | 🔒 Security |
| `noexec` | Prevent execution of binaries on this mount (security hardening). | 🔒 Security |
| `fmask=0022` | File mask for default file permissions on FAT32 (755 for files). | 🔒 Security |
| `dmask=0022` | Directory mask for default directory permissions on FAT32 (755 for dirs). | 🔒 Security |
| `compress=zstd:3` | Use Zstandard compression (level 3: good balance between speed and compression ratio). | 💾 Performance/Storage |
| `ssd` | Optimize for SSD/NVMe storage. | 🚀 Performance |
| `discard=async` | Asynchronous TRIM: notify the SSD of freed blocks asynchronously with reduced I/O overhead. | 💾 Performance |
| `subvol=@...` | Mount a specific BTRFS subvolume. | 📂 BTRFS Feature |

> 💡 **Defaults options:** `noatime` already implies `nodiratime`, so specifying both is redundant. In addition, `space_cache=v2` is the default BTRFS space cache implementation on modern kernels and does not need to be explicitly specified in the mount options.

---

### 🔎 Why these mount options?

These options are carefully chosen for:

- 🚀 **Performance**: optimize SSD/NVMe usage and reduce unnecessary filesystem I/O with `noatime`, `ssd` and asynchronous discard.
- 🗜️ **Compression**: use transparent **Zstandard compression** with `compress=zstd:3` to reduce disk usage and I/O while maintaining low CPU overhead.
- 🔒 **Security**: apply `nodev`, `nosuid` and `noexec` only where they make sense, according to the purpose of each subvolume.
- 🛡️ **Reliability**: use BTRFS features such as asynchronous discard to provide a balanced approach between performance, endurance and filesystem reliability.
- 📸 **Snapshot efficiency**: isolate frequently changing or non-system data such as logs, cache, temporary files, VM images and game libraries from the `@` root subvolume.
- 🔄 **System recovery**: keep the complete system state inside `@`, allowing `snapper` to create consistent system snapshots and restore the system after failed updates.
- 🎮 **Game preservation**: isolate `/opt/games` in its own BTRFS subvolume, allowing Steam and standalone game libraries to be preserved and reused independently of the operating system during a reinstall.
- 💾 **Flexible data management**: dedicated BTRFS subvolumes allow independent snapshots, backups, restores and mount options without affecting the system root.

---

### ✅ Quick Summary

| 🎯 Aspect | ⚙️ Strategy |
|---|---|
| SSD/NVMe optimization | `ssd`, `discard=async` |
| Reduce unnecessary writes | `noatime` |
| Compression | `compress=zstd:3` |
| Security hardening | `nosuid`, `nodev`, `noexec` where appropriate |
| Filesystem management | BTRFS subvolumes |
| Snapshot management | `@` root subvolume managed by `snapper` |
| System rollback | BTRFS snapshots of `@` |
| Data isolation | `@home`, `@log`, `@cache`, `@tmp`, `@srv`, `@virt`, `@games` |
| VM preservation | Dedicated `@virt` subvolume |
| Game preservation | Dedicated `@games` subvolume |
| Swap isolation | Dedicated `@swap` subvolume |
| EFI backup preservation | Dedicated `@efibck` subvolume |

---

**✅ READY FOR PRODUCTION 🖥️**

---

## 📖 Manual Installation (Step-by-step)

> 🧠 For advanced users or educational purposes.

> ⚠️ **Secure Boot must be set to "Setup Mode" in the BIOS/UEFI before installation.**  
> This is required to enroll your own Secure Boot keys with `sbctl`.

This section provides every command used to build the system from a blank disk, explaining each step of the installation process.

The guide covers:

- 🧱 **GPT partitioning and BTRFS filesystem creation**
- 🔐 **LUKS2 encryption with TPM2 auto-unlocking and passphrase fallback**
- 🗂️ **BTRFS subvolume creation and mounting**
- 📸 **Snapper configuration for system snapshots and rollback**
- 📦 **Base system installation**
- 🧰 **System configuration inside the chroot environment**
- 🧬 **Unified Kernel Image (UKI) generation and Secure Boot signing**
- ⚙️ **EFI configuration and direct boot entry creation**
- 🧵 **zRAM configuration**
- 🌀 **Encrypted BTRFS swap file configuration**
- 🛡️ **Post-install hardening and system optimization**
- 🛟 **Fallback UKI configuration for boot recovery**
- 🗄️ **Automatic EFI partition backup and recovery setup**

### 🧱 Step 1 — Pre-Installation Setup

- ⌨️ (Optional) Set keyboard layout to French

```bash
loadkeys fr
```

- 🧼 Clean existing EFI entries if needed (replace X with the entry number)

```bash
efibootmgr
efibootmgr -b X -B
```

- 🔐 Update GPG keys from live environment (recommended before installing)

```bash
pacman -Sy archlinux-keyring
```

### 💽 Step 2 — Disk Partitioning (GPT)

- ⚙️ Partition the disk: EFI (500MB) + LUKS root (rest of disk)

```bash
sgdisk --clear --align-end \
  --new=1:0:+500M --typecode=1:ef00 --change-name=1:"EFI system partition" \
  --new=2:0:0 --typecode=2:8309 --change-name=2:"Linux LUKS" \
  /dev/nvme0n1
```

### 🧼 Step 3 — Main Filesystem Creation

- 🧴 Format EFI partition (optimized for NVMe 4K sector size)

```bash
mkfs.vfat -F 32 -n "SYSTEM" -S 4096 -s 1 /dev/nvme0n1p1
```

- 🔐 Create LUKS2 encrypted container with strong encryption options

```bash
cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha512 \
  --iter-time 5000 --key-size 512 --pbkdf argon2id \
  --label "Linux LUKS" --sector-size 4096 --use-urandom \
  --verify-passphrase luksFormat /dev/nvme0n1p2
```

- 🔓 Open the LUKS container as /dev/mapper/cryptarch

```bash
cryptsetup --allow-discards --persistent open --type luks2 /dev/nvme0n1p2 cryptarch
```

- 🧊 Format the unlocked LUKS volume with BTRFS (4K sectors)
```bash
mkfs.btrfs -L "Arch Linux" -s 4096 /dev/mapper/cryptarch
```

### 🌳 Step 4 — BTRFS Subvolume Layout

- 🪵 Mount the root BTRFS volume temporarily
```bash
mount -o rw,noatime,compress=zstd:3,ssd,discard=async,commit=120 /dev/mapper/cryptarch /mnt
```

- 📂 Create BTRFS subvolumes
```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@efibck
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@virt
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@srv
btrfs subvolume create /mnt/@games
```

- 🔓 Unmount the volume before remounting subvolumes individually
```bash
umount /mnt
```

### 🛠️ Step 5 — Mount Subvolumes & Prepare System

- 🔧 Mount root subvolume
```bash
mount -o rw,noatime,compress=zstd:3,ssd,discard=async,commit=120,subvol=@ \
  /dev/mapper/cryptarch /mnt
```

- 🗂️ Create necessary mount points
```bash
mkdir -p /mnt/{efi,.swap,.snapshots,.efibackup,var/{log,tmp,cache,lib/libvirt/images},home,srv,opt/games}
```

- 🖥️ Mount EFI system partition (read-only, noexec for safety)
```bash
mount -o rw,noatime,nodev,nosuid,noexec,fmask=0022,dmask=0022 \
  /dev/nvme0n1p1 /mnt/efi
```

- 🧷 Mount other BTRFS subvolumes
```bash
mount -o rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,commit=120,subvol=@swap /dev/mapper/cryptarch /mnt/.swap
mount -o rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,commit=120,subvol=@snapshots /dev/mapper/cryptarch /mnt/.snapshots
mount -o rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,commit=120,subvol=@efibck /dev/mapper/cryptarch /mnt/.efibackup
mount -o rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,commit=120,subvol=@log /dev/mapper/cryptarch /mnt/var/log
mount -o rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,commit=120,subvol=@tmp /dev/mapper/cryptarch /mnt/var/tmp
mount -o rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,commit=120,subvol=@cache /dev/mapper/cryptarch /mnt/var/cache/pacman/pkg
mount -o rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,commit=120,subvol=@virt /dev/mapper/cryptarch /mnt/var/lib/libvirt/images
mount -o rw,noatime,nodev,nosuid,compress=zstd:3,ssd,discard=async,commit=120,subvol=@home /dev/mapper/cryptarch /mnt/home
mount -o rw,noatime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,commit=120,subvol=@srv /dev/mapper/cryptarch /mnt/srv
mount -o rw,noatime,nodev,nosuid,compress=zstd:3,ssd,discard=async,commit=120,subvol=@games /dev/mapper/cryptarch /mnt/opt/games
```

### 💾 Step 6 — Create Swap File

- 🛏️ Create 4GB swap file on BTRFS subvolume
```bash
btrfs filesystem mkswapfile --size 4g /mnt/.swap/swapfile
chmod 600 /mnt/.swap/swapfile
```

> 🔐 **Note:** The swap file is **not enabled at this stage**.
>
> Arch Aegis uses an **ephemeral encrypted swap** configured through **`/etc/crypttab`**, using a random key generated from **`/dev/urandom`** at every boot.
>
> The encrypted swap mapping and the `swapon` command will therefore be configured later in the installation guide, once the encrypted swap device has been properly configured.

### 📦 Step 7 — Install Base System

- 🧱 Install base packages, kernel + firmwares, EFI tools, btrfs support, text editor, secure boot tools, splash screen and zRam generator service
```bash
pacstrap /mnt \
  base base-devel linux linux-headers linux-firmware amd-ucode neovim efibootmgr btrfs-progs sbctl plymouth zram-generator
```
> 💡 `base-devel` is required for building packages from the AUR or compiling software from source, and `linux-headers` is needed for DKMS to build and maintain kernel modules.

### 🗂️ Step 8 — Generate fstab

- 📄 Generate fstab with UUIDs
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

- 🔍 (Optional) Review fstab and check "0 1" to enable fsck on `/`
```bash
cat /mnt/etc/fstab
```

- Content:
```bash
UUID=<BTRFS-UUID-PARTITION>      /      btrfs      rw,noatime,compress=zstd:3,ssd,discard=async,commit=120,subvol=/@      0 1
```

> 💡 **Note:** The first value controls the legacy `dump` backup utility and is normally set to `0`. The second value controls the order in which filesystems are checked by `fsck`: `1` for the root filesystem and `2` for other filesystems.

> 📝 `fstab` uses the last two fields to control `dump` and filesystem checks:
>
> | Value | 🔎 Description |
> |-------|----------------|
> | `0 0` | 🚫 Disable `dump` and do not check the filesystem automatically with `fsck`. |
> | `0 1` | 💾 Disable `dump` and check the filesystem first with `fsck` — used for `/`. |
> | `0 2` | 💾 Disable `dump` and check the filesystem after `/` — used for other filesystems. |

> 🔐 The `UUID=<...>` values above are placeholders. `genfstab` will automatically generate the correct UUID entries for the mounted filesystems. Review the generated file and verify that the mount options and filesystem check values are correct before continuing.

### 🚪 Step 9 — Enter Chroot

- 🌀 Change root into new system

```bash
arch-chroot /mnt
```

### 🌐 Step 10 — Keyboard & Locale Configuration

- ⌨️ Set virtual console keyboard to French

```bash
nvim /etc/vconsole.conf
```

- Content:

```bash
KEYMAP=fr
FONT=lat9w-16
```

- 🧩 Set X11 keyboard layout

```bash
localectl set-x11-keymap fr pc105 azerty compose:rctrl
```
> 💡 This ensures correct keyboard compatibility with Xorg/XWayland apps and proper layout support in display managers like Plasma Login Manager (used by KDE Plasma).

- 🌍 Set system-wide locale

```bash
nvim /etc/locale.conf
```

- Content:

```bash
LANG=fr_FR.UTF-8
LC_COLLATE=C
LC_MESSAGES=en_US.UTF-8
```

- 🔓 Enable required locales

```bash
nvim /etc/locale.gen
```

- Uncomment:

```bash
en_US.UTF-8 UTF-8
fr_FR.UTF-8 UTF-8
```

- ⚙️ Generate locale definitions

```bash
locale-gen
```

### 🔢 Step 11 — TTY Behavior (Enable NumLock)

- 🧷 Create drop-in to activate NumLock automatically on TTY login

```bash
mkdir /etc/systemd/system/getty@.service.d
nvim /etc/systemd/system/getty@.service.d/activate-numlock.conf
```

- Content:

```bash
[Service]
ExecStartPre=/bin/sh -c 'setleds -D +num < /dev/%I'
```

> 💡 This enables NumLock automatically when a getty session starts on a virtual terminal (TTY).

### 🖥️ Step 12 — Host Identity Configuration

- 🏷️ Set system hostname

```bash
nvim /etc/hostname
```

- Content:

```bash
lianli-arch
```

- 🧭 Set hosts file entries for local networking

```bash
nvim /etc/hosts
```

- Content:

```bash
127.0.0.1      localhost
::1            localhost
127.0.1.1      lianli-arch.zenitram lianli-arch
192.168.1.101  lianli-arch.zenitram lianli-arch
```

### 🕒 Step 13 — Timezone & Clock Setup

- 🌍 Set system timezone

```bash
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
```

- ⏱️ Sync hardware clock with system time

```bash
hwclock --systohc
```

> 💡 This synchronizes the hardware clock with the configured system time.

### 🧩 Step 14 — Initramfs Configuration (AMDGPU Module, Systemd, LUKS, Keyboard)

- ⚙️ Edit initramfs modules and hooks to include AMDGPU driver before anything, systemd & encryption
```bash
nvim /etc/mkinitcpio.conf
```

- Content:
```bash
MODULES=(amdgpu)

HOOKS=(systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems)
```

- 🔐 Setup encrypted volume for systemd to unlock via TPM2
```bash
nvim /etc/crypttab.initramfs
```

- Content:
```bash
cryptarch UUID=<nvme-UUID> none tpm2-device=auto,password-echo=no,x-systemd.device-timeout=0,timeout=0,no-read-workqueue,no-write-workqueue,discard
```

- Get `<nvme-UUID>` on neovim:
```bash
:read ! lsblk -dno UUID /dev/nvme0n1p2
```

### 🧵 Step 15 — Kernel Command Line Configuration (UKI + disable zswap)

- ⚙️ Root and logging options (read-only fs is handled by systemd and to fsck /)
```bash
nvim /etc/cmdline.d/01-root.conf
```

- Content:
```bash
root=/dev/mapper/cryptarch rootfstype=btrfs rootflags=subvol=@ ro loglevel=3 quiet splash
```

- 🧠 Disable kernel zswap to avoid duplicate swap compression when using zRam as primary swap device
```bash
nvim /etc/cmdline.d/02-zswap.conf
```

- Content:
```bash
zswap.enabled=0
```

### 🧬 Step 16 — Initramfs Preset for Unified Kernel Image (UKI)

- 🔧 Setup mkinitcpio preset to generate a UKI
```bash
nvim /etc/mkinitcpio.d/linux.preset
```

- Content only:
```bash
ALL_kver="/boot/vmlinuz-linux"
PRESETS=('default')
default_uki="/efi/EFI/Linux/arch-linux.efi"
```
> 💡 `default_options="--splash=/usr/share/systemd/bootctl/splash-arch.bmp"` is commented out by default and can be uncommented to enable the splash screen, but it may be redundant if Plymouth is used.

### 🔐 Step 17 — Secure Boot with sbctl

- 🔑 Create Secure Boot keys
```bash
sbctl create-keys
```

- 📥 Enroll custom keys and micr0$0ft💩 keys
```bash
sbctl enroll-keys -m
```

- 🛠️ Generate the Unified Kernel Image
```bash
mkdir -p /efi/EFI/Linux
mkinitcpio -p linux
```

> ℹ️ Note: TPM2-based disk decryption will be configured after the first reboot to ensure the system is fully initialized and all required services are available.

### 💻 Step 18 — EFI Boot Entry

- 🧷 Register UKI with UEFI firmware
```bash
efibootmgr --create --disk /dev/nvme0n1 --part 1 \
  --label "Arch Linux" --loader /EFI/Linux/arch-linux.efi --unicode
```

### 🧠 Step 19 — zRam Setup

- ⚙️ Configure zRam swap device (primary in-memory compressed swap)
```bash
nvim /etc/systemd/zram-generator.conf
```

- Content (balanced gaming + desktop performance):
```bash
[zram0]
zram-size = min(ram / 4, 8 * 1024)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
```

- 🧮 Configure kernel virtual memory parameters for zRam-based swap behavior
```bash
nvim /etc/sysctl.d/99-vm-zram-parameters.conf
```

- Content (low-latency desktop + gaming responsiveness):
```bash
vm.swappiness = 20
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
```

### 🔄 Step 20 — Encrypted Swap Setup

- 🔐 Add encrypted swap mapping using `/dev/urandom` (secure swapfile via device-mapper)
```bash
nvim /etc/crypttab
```

- Content:
```bash
swap      /.swap/swapfile      /dev/urandom      swap,cipher=aes-xts-plain64,sector-size=4096
```

- 📄 Add swap entry with low priority (fallback to zram)
```bash
nvim /etc/fstab
```

- Content:
```bash
#	/.swap/swapfile      ENCRYPTED FALLBACK SWAP
/dev/mapper/swap      none      swap      pri=0      0 0
```

### 📦 Step 21 — Pacman Configuration

- 📦 Enable multilib, candy theme, parallel downloads & ignore snapper cron jobs
```bash
nvim /etc/pacman.conf
```

- Content:
```bash
NoExtract = etc/cron.hourly/snapper
Color
ParallelDownloads = 10
ILoveCandy

[multilib]
Include = /etc/pacman.d/mirrorlist
```

### 🌐 Step 22 — Network Configuration
> 🔀 Choose one network management method depending on your setup
> - ⚙️ `systemd-networkd` → lightweight, minimal, server-friendly, wired only
> - 🖥️ `NetworkManager` → recommended for desktop environments (e.g. KDE Plasma, GNOME) with Wi-Fi support

####  ⚙️ Option A — systemd-networkd (Only Wired, Minimal & Lightweight)

- 📡 Configure wired interface for DHCP, mDNS, and IPv6
```bash
nvim /etc/systemd/network/20-wired.network
```

- Content:
<details>
<summary>📄 <code>20-wired.network</code> content (click to expand)</summary>

```bash
[Match]
Name=eno* ens* enp* eth*

[Link]
RequiredForOnline=routable

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes
MulticastDNS=yes

[DHCPv4]
RouteMetric=100

[IPv6AcceptRA]
RouteMetric=100
```
</details>

####  ⚙️ Option B — NetworkManager (Desktop-Friendly, Wi-Fi Ready)
> 💡 Recommended if you plan to use KDE Plasma, GNOME, or need Wi-Fi support

- 📦 Install NetworkManager
 ```bash
pacman -Syy networkmanager
```

### 🔌 Step 23 — Basic Packages: Bluetooth, Snapper, Pacman Cache Service, Reflector, Firewall

- 📦 Install essential tools
```bash
pacman -Syy bluez snapper pacman-contrib reflector firewalld
```

### 🕰️ Step 24 — Time Sync with French NTP Servers

- ⏲️ Set systemd-timesyncd to use French pool servers with iburst
```bash
nvim /etc/systemd/timesyncd.conf
```

- Content:
```bash
[Time]
NTP=0.fr.pool.ntp.org 1.fr.pool.ntp.org 2.fr.pool.ntp.org 3.fr.pool.ntp.org
FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
```

### 🚀 Step 25 — I/O Scheduler Tuning for NVMe

- 📉 Disable I/O scheduler on NVMe device to use none (for performance)
```bash
nvim /etc/udev/rules.d/60-schedulers.rules
```

- Content:
```bash
ACTION=="add|change", KERNEL=="nvme[0-9]*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="none"
```

### 🧭 Step 26 — DNS Stub Resolver via systemd-resolved
> ⚠️ Only apply this step if you are using *systemd-networkd* (from Step 23)
> ⏭️ Skip this step if you selected *NetworkManager*

- 🔁 Link stub resolver to `/etc/resolv.conf`
```bash
ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

### 🌐 Step 27 — Reflector Configuration (Update Mirrorlist)

- 🌍 Optimize pacman mirrors by age, country, and protocol
```bash
nvim /etc/xdg/reflector/reflector.conf
```

- Content:
```bash
--save /etc/pacman.d/mirrorlist
--country France,Germany,Netherlands
--protocol https
--latest 5
--sort age
```

### ⚙️ Step 28 — Enable Key Services (Networking, Bluetooth, Time, Firewall, Maintenance)

- 🌐 Enable network services (based on your previous choice)

- ⚙️ If using *systemd-networkd*:
```bash
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
```

- 🖥️ If using *NetworkManager*:
```bash
systemctl enable NetworkManager.service
```

- 🔧 Enable essential system services
```bash
systemctl enable bluetooth.service
systemctl enable systemd-timesyncd.service
```

- 🧱 Enable firewall service
```bash
systemctl enable firewalld.service
```

- 🧹 Enable maintenance timers (package cache cleaner & mirrorlist updater)
```bash
systemctl enable paccache.timer
systemctl enable reflector.timer
```

- 🚫 Disable hibernation-related targets (not used / not supported in this setup)
```bash
systemctl mask hibernate.target hybrid-sleep.target
```
> This disables hibernation and hybrid sleep at the systemd level.
> - Swap is encrypted with a non-persistent key, making hibernation unusable  
> - It prevents any accidental suspend-to-disk attempts  
> - It keeps the system configuration cleaner and more explicit
>  
> 💡 On KDE Plasma, this also removes the hibernation option from the power menu, making it cleaner and less confusing.

### 🧰 Step 29 — Change System Editor and Visualiser

- 📝 Define default system editor (used by system tools like systemctl edit, git, etc.)
```bash
nvim /etc/environment
```

- Content:
```bash
EDITOR=nvim
VISUAL=nvim
```

- 🔄 Apply changes immediately (current shell)
```bash
export EDITOR=nvim
```

### 🔑 Step 30 — Configure sudo

- 🛡️ Grant sudo to wheel group
```bash
visudo
```

- Content:
```bash
%wheel ALL=(ALL:ALL) ALL
```

### 🚧 Step 31 — Compilation Optimization (makepkg)

- 🧰 Tune makepkg flags for native arch, use /tmp for build
```bash
nvim /etc/makepkg.conf
```

- Content:
```bash
CFLAGS="-march=native -O2 -pipe ..."
MAKEFLAGS="-j$(nproc)"
BUILDDIR=/tmp/makepkg
```

- 🦀 Optimize Rust build flags
```bash
nvim /etc/makepkg.conf.d/rust.conf
```

- Content:
```bash
RUSTFLAGS="-C opt-level=2 -C target-cpu=native"
```

### 🔇 Step 32 — Disable HDMI Audio

- 🔕 Blacklist HDMI audio module
```bash
nvim /etc/modprobe.d/blacklist.conf
```

- Content:
```bash
blacklist snd_hda_intel
```

### 🔒 Step 33 — Disable Webcam Microphone

- 🎙️ Block Logitech webcam microphone via udev rule
```bash
nvim /etc/udev/rules.d/90-blacklist-webcam-sound.rules
```

- Content:
```bash
SUBSYSTEM=="usb", DRIVER=="snd-usb-audio", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="085c", ATTR{authorized}="0"
```

### ⚡ Step 34 — Allow games Group to Read CPU Power

- 🎮 Grant members of the games group permission to read CPU power (via Intel RAPL interface).
```bash
nvim /etc/udev/rules.d/70-intel-rapl.rules
```

- Content:
```bash
SUBSYSTEM=="powercap", KERNEL=="intel-rapl:0", RUN+="/usr/bin/chgrp games /sys/%p/energy_uj", RUN+="/usr/bin/chmod g+r /sys/%p/energy_uj"
```

> ✅ This ensures users in the `games` group can access CPU energy readings without requiring root privileges — useful for monitoring tools or performance overlays.

### 🔐 Step 35 — Set Root Password

- 🔑 Set root password
```bash
passwd root
```

### 🚪 Step 36 — Exit chroot, Unmount, Reboot into Firmware Setup

- 👋 Exit chroot, unmount and reboot into UEFI/BIOS to check if Secure Boot is enabled
```bash
exit
umount -R /mnt
systemctl reboot --firmware-setup
```

### 🛡️ Step 37 — LUKS TPM2 Key Enrollment

- 🔒 Enroll TPM2 key (PCR 0 = firmware, PCR 7 = Secure Boot state)
```bash
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
```

### Step 38 — 🎮 Shared games directory (multi-user Steam library)

- 🕹️ Allow access and inheritance for users in the `games` group via ACL
```bash
chown root:games /opt/games
chmod 2775 /opt/games
setfacl -dm g:games:rwx /opt/games
```

### 🧩 Step 39 — Configure Snapper after Reboot

- 🔌 Unmount the default /.snapshots subvolume
```bash
umount /.snapshots
```

- 🗑️ Delete it to avoid conflicts with our custom mount
```bash
rm -r /.snapshots
```

- 🛠️ Initialize Snapper for root filesystem
```bash
snapper -c root create-config /
```

- ❌ Delete the subvolume Snapper just created (we’ll remount it ourselves)
```bash
btrfs subvolume delete /.snapshots
```

- 📂 Recreate the mount point and mount it
```bash
mkdir /.snapshots
mount /.snapshots
```

- 🔐 Secure the directory
```bash
chmod 750 /.snapshots
```

- 📝 Configure Snapper snapshot settings
```bash
nvim /etc/snapper/configs/root
```

- Content:
```bash
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"

NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="10"

TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
```

### 🛡️ Step 40 — Custom Pacman Hook to Backup /efi

- 🪝 Create a hook to automatically backup /efi before critical updates
```bash
nvim /etc/pacman.d/hooks/10-efi_backup.hook
```

- Content:

<details>
<summary>📄 <code>10-efi_backup.hook</code> content (click to expand)</summary>

```bash
## PACMAN EFI BACKUP HOOK
## /etc/pacman.d/hooks/10-efi_backup.hook

[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Operation = Remove
Target = usr/lib/initcpio/*
Target = usr/lib/firmware/*
Target = usr/lib/modules/*/extramodules/
Target = usr/lib/modules/*/vmlinuz
Target = usr/src/*/dkms.conf

[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Operation = Remove
Target = mkinitcpio
Target = mkinitcpio-git

[Action]
Description = Backing up /efi...
When = PreTransaction
Exec = /usr/local/sbin/efi_backup.sh
```

</details>

- ✍️ Create the backup script
```bash
nvim /usr/local/sbin/efi_backup.sh
```

- Content:

<details>
<summary>📄 <code>efi_backup.sh</code> content (click to expand)</summary>

```bash
#!/bin/bash
## SCRIPT EFI BACKUP
## /usr/local/sbin/efi_backup.sh

tar -czf "/.efibackup/efi-$(date +%Y%m%d-%H%M%S).tar.gz" -C / efi
ls -1t /.efibackup/efi-*.tar.gz | tail -n +4 | xargs -r rm --
```

</details>

- ✅ Make it executable
```bash
chmod +x /usr/local/sbin/efi_backup.sh
```

### ⏲️ Step 41 — Enable Maintenance Timers

- 🕒 Enable regular TRIM
```bash
systemctl enable fstrim.timer
```

- 📸 Enable automatic timeline snapshots
```bash
systemctl enable snapper-timeline.timer
```

- 🧼 Enable automatic snapshot cleanup
```bash
systemctl enable snapper-cleanup.timer
```

### 🧷 Step 42 — Enable Pacman Transaction Snapshots

- 🧩 Install snap-pac to snapshot before and after pacman operations
```bash
pacman -S snap-pac
```

### 🗑️ Step 43 — Clean Snapper Initial Snapshots Manually

- 📋 List snapshots (🔍)
```bash
snapper -c root list
```

- 🧹 Delete a range of snapshots (e.g., snapshots 1 to 2)
```bash
snapper -c root delete 1-2
```

### 📸 Step 44 — Take Initial System Snapshot

- 🧊 Manually create the first system snapshot after full setup
```bash
snapper -c root create -d "init"
```

---

## ❓ FAQ

### ❓ Why no bootloader?

Because **UKI** allows booting the kernel directly from the EFI partition — no need for GRUB or systemd-boot.

### ❓ Can I use this on my laptop?

Yes — it's ideal for modern laptops with TPM2 and Secure Boot enabled.

---

## 🛠 Requirements

- 🖥️ UEFI firmware
- 🧩 TPM 2.0 module
- 🧷 Secure Boot support
- 💿 Recent Arch Linux ISO
- 🌐 Internet access
- 🧮 NVMe drive with 4K physical block size

---

## 📜 License

Licensed under the [MIT License](LICENSE).
Feel free to use, modify, and share!

---

## 👤 Author

Crafted with ❤️ by [joan31](https://github.com/joan31)

> _"Build it clean. Build it solid. Fortress-grade Arch Linux."_
