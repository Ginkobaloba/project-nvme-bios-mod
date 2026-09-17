# 970AD3P2_NVME.FD -- provenance and warnings

## What this is

A DIY-modded Gigabyte BIOS for the **GA-970A-D3P (no S), Revision 2.0**
that adds an `NvmExpressDxe_5` driver to the DXE Driver Volume so the
firmware can enumerate and boot from NVMe SSDs on PCIe adapters.

| Field | Value |
|---|---|
| Filename | `970AD3P2_NVME.FD` |
| Size | 4,194,304 bytes (4 MiB) |
| SHA-256 | `1dc2f8386b974ba1f3469215f0ec78381a8dcfc6d5c370d6074abd55b74483da` |
| Source BIOS | Gigabyte BIOS version `FC` dated 2015-06-01, downloaded from gigabyte.com (the official `GA-970A-D3P (rev. 2.x)` support page) |
| Module inserted | `NvmExpressDxe_5.ffs` (the full variant, not the Small variant) |
| Source of the module | Win-Raid main NVMe guide: <https://winraid.level1techs.com/t/howto-get-full-nvme-support-for-all-systems-with-an-ami-uefi-bios/30901> |
| Tool used | UEFITool (classic, not the NE variant), per the Win-Raid guide |
| Pad-file diff verified | Yes. Side-by-side comparison of the original and modded BIOSes in UEFITool showed the only difference was the new `NvmExpressDxe_5` module in the DXE Driver Volume. No Pad-files were added, removed, moved, or resized. |
| Flashed on | 2026-05-07 |
| Flashed via | Gigabyte Q-Flash (F8 in BIOS), USB stick FAT32 |
| Chips flashed | M_BIOS only. B_BIOS retained as the original-BIOS rollback safety net. |
| Verified post-flash | Yes. NVMe SSD on PCIe x4 adapter appears as a Boot Option in the BIOS. |

## Compute the SHA-256 yourself before flashing

On Windows:

```powershell
Get-FileHash -Algorithm SHA256 .\970AD3P2_NVME.FD
```

If the hash you compute does not match `1dc2f838...4483da`, do not flash.
The file may have been corrupted in transit or replaced.

## Hard warnings

This BIOS is for **one specific board**: the **Gigabyte GA-970A-D3P (no
S), Revision 2.0**.

It is not for:

- GA-970A-D3P Rev 1.x
- GA-970A-DS3P (with the S) any revision
- GA-970A-UD3P any revision
- GA-970A-D3 (no P)
- Any other Gigabyte board

The DXE Driver Volume layout, microcode tables, and chipset
configuration in this BIOS are specific to the D3P (no S) Rev 2.0
hardware. Flashing it on the wrong board is a likely brick scenario
that DualBIOS may not cleanly recover from if both chips end up with
the wrong image.

**Confirm the silkscreen on your PCB before flashing.** Look for the
exact characters between `GA-970A-` and `-rev`. If you see anything
other than `D3P` (no S), this file is not for you.

## How it was made (one-paragraph version)

Downloaded the official `FC` BIOS for `GA-970A-D3P (rev. 2.x)` from
gigabyte.com. Opened it in UEFITool. Located the DXE Driver Volume
(the one containing the `CSMCORE` module). Right-clicked the bottom
DXE driver in that volume, picked `Insert after...`, and selected
`NvmExpressDxe_5.ffs` from the Win-Raid main NVMe guide. Saved the
modded image. Diffed the original and modded BIOSes in UEFITool side
by side to confirm the only change was the new module and no
Pad-files had been disturbed. Copied the result to a freshly
FAT32-formatted USB 2.0 stick. Booted the board, hit F8 for Q-Flash,
flashed the M_BIOS chip from the stick. Left the B_BIOS chip on the
stock `FC` BIOS as a clean rollback target. Rebooted, re-applied BIOS
settings, NVMe appeared as a Boot Option.

For the full step-by-step including verification, see
`docs/runbooks/diy-mod-procedure.md`.
