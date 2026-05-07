# HANDOFF_2026-05-07_prior-session-context

This handoff is a verbatim capture of the context Drew brought into the
session that scaffolded this repo. It is preserved as project history so
that any future session can read what we knew at scaffold time without
having to dig through chat logs.

The text below is the original handoff Drew dropped into the chat that
established this project.

---

# Handoff: BIOS Mod & Windows Install on Gigabyte GA-970A-D3P Rev 2.0

## Current state

Working on a hand-me-down PC ("Mark's PC"). Goal is to get Windows 10 Pro
installed on a new NVMe SSD that's mounted via a PCIe x4-to-NVMe adapter
card. Hit a wall: motherboard BIOS predates NVMe boot support, so even
after a successful Windows install, the BIOS won't see the NVMe as a
bootable device.

## Hardware specifics

Motherboard: Gigabyte GA-970A-D3P, Revision 2.0 (confirmed via PCB
silkscreen)

- Socket AM3+ (AMD FX-series CPU)
- Current BIOS: version FC, dated 06/01/2015
- Has DualBIOS (M_BIOS and B_BIOS chips, both visible on board)
- Chipset: AMD 970
- PCIe slots are PCIe 2.0 (NVMe will cap around 1,800-2,000 MB/s on this
  board)
- AHCI mode confirmed enabled
- Currently installed: Sapphire AMD GPU (visible in original PCIe x16
  slot), NVMe adapter card in secondary PCIe x4 slot

Storage:

- New NVMe SSD on PCIe x4 adapter card (the boot target)
- Old SATA HDD (currently Boot Option #1 in BIOS as "P3: ATA...")
- DVD drive on SATA
- 4 SATA cables total available, 1 used by DVD

RAM: DDR3 1600 MHz. Originally 4 sticks, currently 2 (pulled half during
troubleshooting). Single-stick install attempts also failed.

PSU: Unknown wattage, original to the build, supplies the Sapphire GPU
and existing drives.

## What's been tried

1. Multiple Windows 10 install attempts all failed with error 0x8007025D
   ("Windows cannot install required files"). Failures occurred at
   varying progress percentages, suggesting stochastic data corruption
   during file extraction.
2. USB port swaps from USB 3.0 (blue) to USB 2.0 (black) helped but did
   not solve.
3. RAM reduction to single/half sticks did not solve.
4. PCIe adapter reseated. No change.
5. Fresh ISO downloaded from microsoft.com (Windows 10, x64, build dated
   12/4/2023).
6. USB rewritten with Rufus instead of Media Creation Tool. Settings:
   GPT partition scheme, UEFI (non CSM), NTFS, 4096 cluster size, with
   bad-blocks check enabled (1 pass).
7. Rufus flagged the ISO as containing a "revoked UEFI bootloader"
   (known BlackLotus revocation issue, expected for ISOs from before
   the revocation, not malware). Workaround is to disable Secure Boot.
8. Discovered the actual root cause: the BIOS is too old to support NVMe
   boot. The NVMe drive does not appear in Boot Option #1 dropdown at
   all.

## Critical BIOS settings to change before any further install attempts

In Gigabyte BIOS, BIOS Features tab:

- OS Type: change from "Other OS" to Windows 8/10 WHQL
- Boot Mode Selection: change to UEFI Only
- Storage Boot Option Control: change from "Legacy" to UEFI Only
- Secure Boot: Disabled (because of revoked bootloader warning)
- CSM: Disabled

## The two paths forward (decision point)

### Option 1: BIOS mod (current direction)

Flash a community-modded BIOS from Win-Raid forum that adds NVMe driver
support, allowing native NVMe boot. DualBIOS provides safety net for
failed flashes.

Critical caveat: The Win-Raid community has well-documented NVMe mods
for Rev 1.0 of this board. Rev 2.0 is less common and a Rev 2.0-specific
modded BIOS may or may not exist. Verifying availability is the next
blocker. Flashing a Rev 1.0 BIOS onto a Rev 2.0 board is a real brick
scenario that DualBIOS may not cleanly recover.

Steps if Rev 2.0 mod is available:

1. Search winraid.level1techs.com for "GA-970A-D3P Rev 2.0 NVMe"
2. Find thread explicitly stating the mod is for Rev 2.0
3. Read full thread, look for multiple successful user reports
4. Verify BIOS filename matches Rev 2.0 naming
5. Copy modded BIOS to FAT32 USB stick root
6. Reboot, F8 in BIOS launches Q-Flash
7. Update Main BIOS from file
8. After flash, NVMe should appear as bootable device in Boot Option
   dropdown

### Option 2: Bootloader workaround (fallback if Rev 2.0 mod doesn't exist)

Use Clover or rEFInd on a SATA drive (the existing HDD works fine,
doesn't need to be dedicated, bootloader only takes ~100-500 MB EFI
partition). BIOS boots SATA drive's EFI bootloader, which chainloads to
NVMe Windows. No brick risk, slight ongoing complexity.

## Recommendations for the Cowork session

1. Search Win-Raid first. Confirm whether a Rev 2.0 modded BIOS for
   GA-970A-D3P actually exists with documented successful flashes. This
   is the critical gate.
2. Cross-validate with another model. Niche forum-based BIOS modding
   info is exactly the kind of thing where different training data
   lands differently. Worth getting a second opinion specifically on
   "Does a known-good NVMe-modded BIOS for Gigabyte GA-970A-D3P Rev 2.0
   exist on Win-Raid as of 2026?"
3. If Rev 2.0 mod exists: Get exact filename, exact thread URL, exact
   instructions, exact warnings. Don't trust paraphrasing, work from
   the source.
4. If Rev 2.0 mod does not exist: Pivot to Option 2 (Clover/rEFInd
   bootloader workaround). Don't force a Rev 1.0 BIOS onto a Rev 2.0
   board.
5. Whichever path: apply the BIOS settings changes above (UEFI mode,
   Storage Boot to UEFI, OS Type to Windows 8/10 WHQL, Secure Boot off)
   before next install attempt. The hybrid Legacy/UEFI mode the system
   was in is likely contributing to the install errors.

## Outstanding questions for next session

- Does a Rev 2.0 NVMe modded BIOS exist on Win-Raid?
- Exact CPU model in the system (FX-8350? 8320? 6300?) -- confirms VRM
  and BIOS compatibility expectations
- PSU wattage -- if 500W or less, may be marginal for sustained load
  and could be contributing to install corruption
- Whether the existing HDD has anything important on it (probably not,
  user said docs are not on main HDD)

## Why the install kept failing (probable explanation)

The 0x8007025D errors at random progress points were likely the result
of the system being in a weird hybrid Legacy/UEFI boot state. With
Storage Boot Option Control set to "Legacy" but the install media
written as GPT/UEFI by Rufus, the installer was getting confused about
what to do. Fixing the BIOS settings above may resolve this independent
of any BIOS modding, though the NVMe boot question still has to be
solved separately.

---

## Editor's notes (added during scaffolding)

- This handoff says **GA-970A-D3P** (no S) and states the silkscreen
  was confirmed. Drew's earlier verbal answer in the same chat said
  **DS3P** (with S). The two are different boards with different mod
  status on Win-Raid. This is now an explicit open question on
  `docs/hardware/target-system.md` and ADR-0001.
- The "Rev 1.0 vs Rev 2.0" warning above is the right intuition. The
  more relevant warning we surfaced during scaffolding is **D3P vs
  DS3P** (the letter, not the revision). Both versions of that warning
  point at the same conclusion: do not flash without a fresh
  silkscreen confirmation.

## Next Session Onboarding

> Future sessions: read `C:\dev\SESSION_PROTOCOL.md`, then `CLAUDE.md` in
> this project, then this file, then run `vstart`.
