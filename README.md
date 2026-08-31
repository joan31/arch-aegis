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
  - `@swap`
  - `@snapshots`
  - `@efibck`
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
- Provides a quick boot option if the standard UKI or kernel causes a boot failure
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

> This is the storage layout used by **Arch Fortress**, based on a secure and flexible setup combining LUKS2, BTRFS, and EFI boot with UKI.

### 💽 Partition Table (GPT - `/dev/nvme0n1`)

| Partition        | Type              | FS    | Mount Point | Size | Description                         |
|------------------|-------------------|-------|-------------|------|-------------------------------------|
| `/dev/nvme0n1p1` | EFI System (ef00) | FAT32 | `/efi`      | 500M | EFI System Partition (boot via UKI) |
| `/dev/nvme0n1p2` | Linux LUKS (8309) | LUKS2 | (LUKS)      | ~2TB | Encrypted root volume               |

---

### 🔐 Encrypted Volume

- `/dev/nvme0n1p2` is encrypted using **LUKS2 + TPM2**
- Mapped as `/dev/mapper/cryptarch`
- Inside: **BTRFS** filesystem with multiple subvolumes

---

### 🌳 BTRFS Subvolume Layout

| Subvolume    | Mount Point               | Description                       |
|--------------|---------------------------|-----------------------------------|
| `@`          | `/`                       | Root system                       |
| `@home`      | `/home`                   | User data                         |
| `@pkg`       | `/var/cache/pacman/pkg`   | Pacman cache                      |
| `@log`       | `/var/log`                | System logs                       |
| `@tmp`       | `/var/tmp`                | Temporary files                   |
| `@srv`       | `/srv`                    | Server data                       |
| `@vms`       | `/var/lib/libvirt/images` | Virtual machines                  |
| `@games`     | `/opt/games`              | Optional game data                |
| `@swap`      | `/.swap`                  | Encrypted swapfile (e.g. 4GB)     |
| `@snapshots` | `/.snapshots`             | Snapper snapshots                 |
| `@efibck`    | `/.efibackup`             | EFI partition backups (automated) |

---

🧠 This structure is designed for:
- Granular snapshotting with `snapper`
- Easy backup & restore
- Separation of concerns (logs, cache, VMs, etc.)
- Improved performance & maintenance

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
└──────────────────────────────────────────────────┘
```

BTRFS Subvolumes (inside /dev/mapper/cryptarch):

```
┌────────────────────────────────────────────────────────────────────────┐
│ @           → /                                      ← Root filesystem │
│ @home       → /home                                                    │
│ @log        → /var/log                                                 │
│ @tmp        → /var/tmp                                                 │
│ @srv        → /srv                                                     │
│ @pkg        → /var/cache/pacman/pkg                                    │
│ @vms        → /var/lib/libvirt/images                                  │
│ @games      → /opt/games                                               │
│ @snapshots  → /.snapshots                                ← For Snapper │
│ @efibck     → /.efibackup                                ← EFI backups │
│ @log        → /var/log                                                 │
│ @swap       → /.swap                    ← Encrypted swapfile (e.g. 4G) │
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
[ Boot into secure, modern Arch Fortress 🔐🛡️ ]
```

---

## 🔧 Mount Options Summary

### 📂 Mount Points and Options

| 📍 Mount Point | 💽 Device | 🗂️ Subvolume | ⚙️ Mount Options |
|---|---|---|---|
| `/` | `/dev/mapper/cryptarch` | `@` | `rw,noatime,nodiratime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/efi` | `/dev/nvme0n1p1` | *(N/A)* | `rw,noatime,nodiratime,nodev,nosuid,noexec,fmask=0022,dmask=0022` |
| `/.swap` | `/dev/mapper/cryptarch` | `@swap` | `rw,noatime,nodiratime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/.snapshots` | `/dev/mapper/cryptarch` | `@snapshots` | `rw,noatime,nodiratime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/.efibackup` | `/dev/mapper/cryptarch` | `@efibck` | `rw,noatime,nodiratime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/var/log` | `/dev/mapper/cryptarch` | `@log` | `rw,noatime,nodiratime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/var/tmp` | `/dev/mapper/cryptarch` | `@tmp` | `rw,noatime,nodiratime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/var/cache/pacman/pkg` | `/dev/mapper/cryptarch` | `@pkg` | `rw,noatime,nodiratime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/var/lib/libvirt/images` | `/dev/mapper/cryptarch` | `@vms` | `rw,noatime,nodiratime,nodev,nosuid,noexec,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/home` | `/dev/mapper/cryptarch` | `@home` | `rw,noatime,nodiratime,nodev,nosuid,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/srv` | `/dev/mapper/cryptarch` | `@srv` | `rw,noatime,nodiratime,nodev,nosuid,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |
| `/opt/games` | `/dev/mapper/cryptarch` | `@games` | `rw,noatime,nodiratime,nodev,nosuid,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120` |

---

### 📖 Mount Options Explanation

| ⚙️ Option | 🔎 Description | 🏷️ Category |
|---|---|---|
| `rw` | Mount as read-write. | 🔧 Default |
| `noatime` | Do not update file access times (improves performance, reduces SSD writes). | 🚀 Performance |
| `nodiratime` | Do not update directory access times (even more efficient than `noatime`). | 🚀 Performance |
| `nodev` | Prevents character/block device files from being interpreted (security hardening). | 🔒 Security |
| `nosuid` | Disable set-user-ID and set-group-ID bits (security hardening). | 🔒 Security |
| `noexec` | Prevent execution of binaries on this mount (security hardening). | 🔒 Security |
| `fmask=0022` | File mask for default file permissions on FAT32 (755 for files). | 🔒 Security |
| `dmask=0022` | Directory mask for default directory permissions on FAT32 (755 for dirs). | 🔒 Security |
| `compress=zstd:3` | Use Zstandard compression (level 3: good balance between speed and compression ratio). | 💾 Performance/Storage |
| `ssd` | Optimize for SSD (disables unnecessary spinning disk optimizations). | 🚀 Performance |
| `discard=async` | Asynchronous TRIM: notify SSD of free blocks asynchronously (less I/O overhead). | 💾 Performance |
| `space_cache=v2` | Improved Btrfs space cache version 2 (better mount speed, reliability). | 🚀 Performance |
| `commit=120` | Flush changes to disk every 120s (reduces write amplification). | 💾 Performance |
| `subvol=@...` | Mount specific Btrfs subvolume. | 📂 Btrfs Feature |

---

### 🔎 Why these mount options?

These options are carefully chosen for:

- 🚀 **Performance**: optimized for SSDs and minimizing unnecessary I/O.
- 🔒 **Security**: limiting execution and device files where not needed.
- 💾 **Reliability**: with Btrfs improvements (`space_cache=v2`, `commit=120`).
- 📂 **Granular subvolume management**: easy snapshot, rollback, backup management.

---

### ✅ Quick Summary

| 🎯 Aspect | ⚙️ Strategy |
|---|---|
| SSD optimization | `ssd`, `discard=async` |
| Reduce writes | `noatime`, `nodiratime`, `commit=120` |
| Compression | `compress=zstd:3` |
| Security hardening | `nosuid`, `nodev`, `noexec` |
| Faster mounts | `space_cache=v2` |
| Granular control | Subvolumes (`@home`, `@swap`, `@log`...) |

---

**✅ READY FOR PRODUCTION 🖥️**

---
