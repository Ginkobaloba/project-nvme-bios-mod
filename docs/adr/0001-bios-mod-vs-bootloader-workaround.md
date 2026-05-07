# ADR 0001: BIOS Mod vs. Bootloader Workaround

- Status: **Accepted** -- recommendation is **Option 2** for our specific board
- Date: 2026-05-07
- Context: First decision record for `project-nvme-bios-mod`. Captures the
  fork the handoff doc identified, and the board-specific resolution.

## Context

The Gigabyte GA-970A series board, Revision 2.0, with BIOS version FC dated
2015-06-01, does not support booting from an NVMe SSD on a PCIe x4 adapter.
The drive can be installed to (Windows Setup completes), but the BIOS does
not list the NVMe device under Boot Option #1, so the system has nowhere
to start from on reboot.

Two paths exist that achieve the same end-state (Windows boots from the
NVMe SSD on each power-on, no manual intervention).

## Option 1: BIOS mod

Flash a community-modded BIOS that adds an NvmExpressDxe DXE driver to the
BIOS's DXE Driver Volume, so the BIOS itself learns to enumerate NVMe
devices as bootable.

**Pros**

- Cleanest end-state. One thing to learn. No bootloader chain to maintain.
- Native UEFI boot: no extra latency, no extra moving parts.
- Frees the SATA HDD for any use, including being removed entirely.
- DualBIOS provides a recovery path for failed flashes.

**Cons**

- Hardware-irreversible operation. Even with DualBIOS, flashing the wrong
  modded BIOS to the wrong revision is a real brick scenario, especially
  if both M_BIOS and B_BIOS get flashed with the bad image.
- Critically depends on a Rev 2.0-specific modded BIOS existing for the
  exact submodel the user has. **This is the open question.**

**Confidence**

| Evidence | Confidence |
|---|---|
| The board is **GA-970A-D3P (no S), Rev 2.0**. | **High.** Confirmed via silkscreen re-check on 2026-05-07. |
| Win-Raid has a confirmed Rev 2.x mod for **GA-970A-DS3P (with S)** with multiple successful flash reports. | High. **Not applicable** to our board. |
| Win-Raid has a delivered Rev 2.0 NVMe-modded BIOS for **GA-970A-D3P (no S)**. | **No evidence found** as of 2026-05-07. The relevant Win-Raid thread is in `BIOS Modding Requests`, not in `Offers: Already modded special BIOSes`. |

Until a delivered Rev 2.0 D3P mod exists on Win-Raid (with multiple
verified successful flashes), Option 1 is not a real option for this
board. A DIY mod (extracting the original D3P BIOS, inserting
NvmExpressDxe_5.ffs ourselves) is technically possible per the Win-Raid
main guide but carries significantly higher risk than using a
community-vetted offer.

## Option 2: Bootloader workaround (Clover or rEFInd)

Install a UEFI bootloader (Clover-EFI or rEFInd) on a small EFI partition
on the existing SATA HDD. The BIOS boots the SATA drive in UEFI mode, the
bootloader enumerates the NVMe via its own NVMe driver, and chainloads the
Windows Boot Manager on the NVMe SSD.

**Pros**

- Zero brick risk. No BIOS flashing involved.
- Works regardless of board submodel and revision.
- Reversible: remove the EFI partition, the bootloader is gone.
- Already documented and recommended by Win-Raid as a fallback method
  (the "Clover-EFI Bootloader Method").

**Cons**

- An extra component in the boot path. One more thing to maintain or
  re-explain to a future user of this PC.
- Requires keeping the SATA HDD permanently in the system, or migrating
  the EFI bootloader to a smaller SATA SSD. The bootloader itself is
  ~100-500 MB.
- Slight added boot time (small, usually under 2 seconds).
- Some Windows updates can disrupt the chainload if Microsoft's bootloader
  reasserts itself. Recoverable but annoying.

## Decision criteria

In priority order:

1. **Confirmed safety.** If Option 1 cannot be made safe for this exact
   board, Option 2 wins automatically.
2. **Cleanliness of end-state.** All else equal, fewer moving parts wins.
3. **Reversibility.** All else equal, the more reversible path wins.
4. **Effort to maintain.** All else equal, the less ongoing work wins.

(1) is the gating concern. (2), (3), (4) only matter if (1) is satisfied.

## Recommendation

**Option 2 (bootloader workaround).** The board is the D3P (no S),
silkscreen-confirmed. No off-the-shelf Rev 2.0 mod exists for this board
on Win-Raid as of 2026-05-07. Option 1 requires either a delivered mod we
don't have, or a DIY mod we can do but shouldn't without a second pair
of expert eyes and an explicit risk decision from Drew.

Specifically:

1. Apply the BIOS settings changes in `docs/hardware/bios-settings.md`
   first. These very likely fix the 0x8007025D installer errors on
   their own and are required for any clean UEFI install.
2. Reinstall Windows 10 onto the NVMe SSD via the UEFI-mode Rufus stick.
3. Install rEFInd (recommended) onto a small EFI partition on the
   existing SATA HDD. Set the SATA HDD as Boot Option #1.
4. Configure rEFInd to default-boot the NVMe Windows entry with a short
   timeout.

See `docs/runbooks/bootloader-workaround.md` for the step-by-step.

## Future re-evaluation

This decision can be revisited if:

- A delivered D3P (no S) Rev 2.0 NVMe mod gets posted on Win-Raid with
  multiple successful flash reports.
- Drew explicitly opts for the DIY mod path with eyes open about the
  brick risk and an outside-expert second opinion lined up.

Either of those events should trigger an ADR-0002 superseding this one.

## Open questions (unrelated to the path decision)

1. Exact CPU model
2. Exact NVMe SSD model
3. Exact PSU wattage (matters for ruling out hardware-marginal install
   errors as a co-contributor to the 0x8007025D failures)
4. Whether the existing HDD has anything important on it (it will host
   the rEFInd EFI partition)

## Status changes

- 2026-05-07: Proposed. Decision deferred pending silkscreen confirmation.
- 2026-05-07: Silkscreen confirmed D3P (no S). Accepted with Option 2 as
  the recommendation.
