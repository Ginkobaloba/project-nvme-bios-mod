# Runbook: Bootloader Workaround (Option 2)

**Pre-conditions:**

- BIOS settings from `docs/hardware/bios-settings.md` have been applied.
- Windows 10 has been installed onto the NVMe SSD using a UEFI-mode USB
  install stick (Rufus, GPT, NTFS).
- A SATA-connected drive is available with at least ~500 MB of free space
  for the EFI System Partition that hosts the bootloader. The existing
  HDD works fine.

The board doesn't need to know how to enumerate NVMe in firmware. We're
going to put a small bootloader on a SATA drive that the BIOS does
understand, and the bootloader will enumerate the NVMe drive itself and
chainload the Windows Boot Manager that lives there.

## Choose a bootloader

Two options, both proven on this kind of setup:

| Bootloader | Pros | Cons |
|---|---|---|
| rEFInd | Simple, polished UI. Auto-detects Windows Boot Manager. Easy to install on Windows. | Slightly larger footprint. |
| Clover-EFI | Long history with Hackintosh and BIOS-mod-adjacent setups. Documented in the Win-Raid guide. | More config, less polish. |

Recommendation: **rEFInd**, unless you specifically know you want Clover.

## Steps for rEFInd

### 1. Download rEFInd

From <https://www.rodsbooks.com/refind/getting.html>. Get the binary
zip (`refind-bin-<version>.zip`).

### 2. Confirm the EFI System Partition layout

On the existing SATA HDD, identify or create an EFI System Partition
(ESP) of at least 200 MB, FAT32. If the HDD currently has an MBR
partition table, you have two choices:

- Reformat the HDD entirely with GPT (you said docs aren't on it, but
  confirm with Mark first).
- Leave the HDD as data drive and put rEFInd on a separate small ESP.

Diskpart commands for option (b), assuming Disk 1 has free space at end:

```
diskpart
list disk
select disk 1
list partition
create partition efi size=200
format quick fs=fat32 label="EFI"
assign letter=S
exit
```

### 3. Install rEFInd to the SATA EFI partition

Extract the rEFInd zip. Run the install batch file from an admin
PowerShell:

```powershell
cd <unzipped refind folder>
.\refind-install.bat --usedefault S:
```

This copies rEFInd's EFI binaries to `S:\EFI\refind\`.

### 4. Tell the BIOS to boot from the SATA drive's EFI

In BIOS, set Boot Option #1 to the SATA HDD's EFI entry (it will
typically show as the drive name with "EFI" or "UEFI:" prefix).

### 5. Reboot, verify

You should see the rEFInd menu. It should auto-discover:

- The Windows Boot Manager on the NVMe SSD
- (Possibly) a Windows entry on the SATA drive if one exists

Pick the NVMe Windows entry. Windows boots normally.

### 6. Set the default boot target

Edit `S:\EFI\refind\refind.conf` to set:

```
default_selection "Windows"
timeout 3
```

A 3-second timeout means the rEFInd menu flashes briefly, then auto-boots
Windows. If Windows is the only OS on the box, you can drop timeout
to 1.

## Steps for Clover

The Win-Raid guide has a writeup ("Clover-EFI Bootloader Method"). Link:
<https://winraid.level1techs.com/t2375f25-Guide-NVMe-boot-without-modding-your-UEFI-BIOS-Clover-EFI-bootloader-method.html>

If we end up going Clover, this section will get expanded with the
specific steps that worked. Until we actually do it, the Win-Raid
writeup is the canonical source.

## Recovery

If the bootloader chain breaks (e.g. after a Windows update):

1. Boot from the Windows install USB.
2. Go to Repair > Troubleshoot > Command Prompt.
3. Run:
   ```
   bcdboot <NVMe-Windows-drive>:\Windows /s S: /f UEFI
   ```
   (where `S:` is the SATA EFI partition rEFInd lives on)
4. Re-run the rEFInd install batch if its EFI entries were overwritten.

## Don't

- Don't put the rEFInd EFI partition on the same drive as a Windows ESP
  unless you understand both. They can fight over `\EFI\Microsoft\` and
  it gets ugly.
- Don't remove the SATA HDD after the bootloader is installed (without
  first migrating the bootloader to whatever drive replaces it). Without
  the bootloader's drive in the system, the board has nothing UEFI to
  boot from again.
