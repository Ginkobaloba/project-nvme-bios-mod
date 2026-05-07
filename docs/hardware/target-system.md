# Target System Specification

Internal nickname: **Mark's PC**.

This file captures everything we know about the box we're working on.

## Board model: confirmed

**Gigabyte GA-970A-D3P (no S), Revision 2.0.** Confirmed via silkscreen
re-check on 2026-05-07. The earlier "DS3P" reading was wrong, and a DS3P
modded BIOS that had been downloaded based on the wrong reading was
deleted before any flashing occurred.

| Model | Status for this project |
|---|---|
| GA-970A-D3P (no S) | **This is our board.** No confirmed delivered Rev 2.0 NVMe-modded BIOS exists on Win-Raid as of 2026-05-07. The Win-Raid thread for this model is in **BIOS Modding Requests**, not in **Offers: Already modded special BIOSes**. |
| GA-970A-DS3P (with S) | Different board. Has a confirmed Rev 2.x mod, but it does not apply to us. Do not flash a DS3P BIOS onto this board. |

Implication: the BIOS-mod path (Option 1) is not currently available off
the shelf for this board. The recommendation in ADR-0001 is **Option 2
(bootloader workaround using rEFInd or Clover)**.

## Motherboard

- Model: **Gigabyte GA-970A-D3P (no S)** -- confirmed via silkscreen 2026-05-07
- Revision: 2.0
- Chipset: AMD 970 (Northbridge) + AMD SB950 (Southbridge)
- Socket: AM3+
- BIOS: AMI Aptio (UEFI), version `FC` dated 2015-06-01
- DualBIOS: yes, both M_BIOS and B_BIOS chips visible on the board
- PCIe: PCIe 2.0 (this caps NVMe at roughly 1.8 to 2.0 GB/s sequential,
  even with a 4-lane adapter)
- DDR3 1600 MHz, 4 DIMM slots (the box originally had 4 sticks; some were
  pulled during troubleshooting)

## CPU

- Family: AMD FX (AM3+)
- Exact model: **unknown, confirm from BIOS POST screen or `wmic cpu get
  name` if Windows boots to anything**

## GPU

- Sapphire AMD GPU in primary PCIe x16 slot
- Exact model: unknown, confirm from device manager or visual inspection

## Storage

- Target boot drive: NVMe SSD (model TBD) on a PCIe x4-to-NVMe adapter
  card, in the secondary PCIe x4 slot
- Existing SATA HDD ("P3: ATA..." in the BIOS), currently Boot Option #1
- DVD drive on SATA
- 4 SATA cables available, 1 used by DVD

The HDD probably does not have anything important on it (per Mark's
statement that docs are not on the main HDD), but **confirm with Mark
before any partition changes**.

## RAM

- DDR3 1600 MHz
- Originally 4 sticks, currently 2 (during troubleshooting)
- Single-stick install attempts also failed during the 0x8007025D errors
- Capacity per stick: TBD

## PSU

- Wattage: **unknown**
- This matters. If the PSU is 500W or under and is feeding the Sapphire
  GPU, sustained loads during install can cause power-related corruption
  that masquerades as Windows install errors. The 0x8007025D errors at
  random progress points are consistent with this kind of issue.
- Action: read the PSU label and write the wattage here.

## Why the install kept failing (probable explanation)

The 0x8007025D ("Windows cannot install required files") errors appeared
at random percentages during repeated install attempts. The most likely
contributors, in rough order:

1. **Hybrid Legacy/UEFI boot state.** Storage Boot Option Control was
   "Legacy" while the Rufus-built USB was GPT/UEFI. The installer was
   confused about which world it lives in. This is fixable just by
   changing BIOS settings, see `bios-settings.md`.
2. **The BIOS doesn't see the NVMe as a boot device at all.** Even if
   the install completes, the system has nowhere to boot from. This is
   the core problem the project exists to solve.
3. **Marginal RAM or PSU.** Plausible secondary contributor.
4. **Bad USB stick.** Less likely after the Rufus-with-bad-blocks-check
   step, but not zero.

The fix for (1) is just BIOS settings. The fix for (2) is the BIOS mod
path or the bootloader workaround. The fix for (3) and (4) is verification
on a different stick / single DIMM / etc.

## Open hardware questions

- ~~Exact board submodel: D3P or DS3P?~~ Resolved 2026-05-07: **D3P (no S)**.
- Exact CPU model
- Exact NVMe SSD model
- Exact PSU wattage
- Whether the existing HDD has anything important on it
