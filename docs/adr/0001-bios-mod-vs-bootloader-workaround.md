# ADR 0001: BIOS Mod vs. Bootloader Workaround

- Status: **Accepted, revised** -- ended up at **Option 1 via DIY** rather than Option 2 (see "Status changes" at the bottom)
- Date: 2026-05-07
- Context: First decision record for `project-nvme-bios-mod`. Captures the
  fork the handoff doc identified, the board-specific resolution, and
  the DIY-mod path that ultimately got executed.

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

## What was actually executed

**Option 1 via DIY mod.** Drew opened the official `FC` BIOS in
UEFITool, inserted `NvmExpressDxe_5.ffs` into the DXE Driver Volume
manually, did a side-by-side Pad-file diff against the original to
confirm no structural drift, and Q-Flashed the result onto M_BIOS only,
leaving B_BIOS on the stock `FC` BIOS as a clean rollback. The NVMe SSD
on PCIe x4 now appears as a Boot Option in the BIOS.

The recommendation in the original draft of this ADR was Option 2
(rEFInd / Clover bootloader). Drew chose the DIY-Option-1 path with
eyes open. The reasoning that made it OK in this specific case:

- **Single-chip flash.** B_BIOS untouched means a brick of M_BIOS is
  recoverable via DualBIOS rollback, which is meaningfully safer than
  the both-chips-flashed scenario the original "Cons" section was
  worried about.
- **Verified Pad-file diff.** Drew confirmed the only structural
  difference between original and modded BIOS was the inserted module.
  This is the step that catches the most common UEFITool footgun.
- **Source BIOS verified.** The `FC` BIOS used as the base was pulled
  directly from gigabyte.com's official D3P Rev 2.x support page, not
  a forum mirror.
- **Module from the canonical source.** `NvmExpressDxe_5` is the
  Win-Raid main-guide-recommended module, used on hundreds of similar
  boards.

The deliverable is committed at `bios/modded/970AD3P2_NVME.FD` with
SHA-256 and full provenance in the sibling `.notes.md`. The procedure
is documented at `docs/runbooks/diy-mod-procedure.md`.

## Option 2 status

Still valid as a fallback. If the DIY mod ever needs to be reverted
(see "Future re-evaluation" below), Option 2 remains the no-brick-risk
path. The runbook is at `docs/runbooks/bootloader-workaround.md` and
will not be removed.

## Future re-evaluation

This ADR may be superseded if:

- The DIY mod turns out to be unstable in practice (random BIOS
  POST failures, weird NVMe enumeration issues, etc.). At that
  point, B_BIOS rollback gets us back to stock and we move to
  Option 2.
- A different, better-tested D3P Rev 2.0 mod surfaces on Win-Raid.
- The board is replaced with something newer that has native NVMe
  support, making the whole question moot.

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
  the original recommendation.
- 2026-05-07 (later): Drew executed Option 1 via DIY mod with UEFITool.
  Modded BIOS verified, flashed to M_BIOS, NVMe is now a Boot Option.
  ADR re-classified as "Accepted, revised." Option 2 retained as
  documented fallback.
