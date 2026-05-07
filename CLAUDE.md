# CLAUDE.md (project-local)

Project: `project-nvme-bios-mod`
Owner: Drew Mattick
Established: 2026-05-07

This file is read by every AI session that opens this project. It is a
companion to `C:\dev\SESSION_PROTOCOL.md` (the global protocol) and the
global Cowork preferences.

## What this project is

We are adding NVMe boot support to a Gigabyte GA-970A series motherboard
(Revision 2.0). The original BIOS predates NVMe boot, so it doesn't list
the NVMe SSD in the boot device dropdown even though Windows can install
to it. Two paths exist: (1) flash a community-modded BIOS that adds an
NvmExpressDxe driver, or (2) install a Clover or rEFInd bootloader on a
SATA drive that chainloads to the NVMe Windows install.

Path 1 is faster and cleaner once running. It also has real brick risk if
a BIOS for the wrong board revision is flashed. Path 2 has no brick risk
and a small amount of ongoing complexity.

## Board identity (resolved)

**Gigabyte GA-970A-D3P (no S), Revision 2.0.** Confirmed via silkscreen
re-check on 2026-05-07. Earlier "DS3P" reading was wrong.

There is no confirmed delivered Rev 2.0 NVMe-modded BIOS on Win-Raid for
the D3P (no S) as of 2026-05-07. The Win-Raid D3P thread is in BIOS
Modding Requests, not in Offers. The current recommendation is therefore
the bootloader workaround (Option 2 in ADR-0001), not a BIOS flash.

If a future session finds that someone has since posted a delivered D3P
Rev 2.0 mod on Win-Raid (with multiple successful flash reports), the ADR
can be revisited.

## Hard rules for AI sessions on this project

1. Never recommend a flash command or flash UI step until the board model
   AND revision are confirmed in writing in the latest handoff doc.
2. Never download a BIOS file from a forum link directly. Surface the link
   to the user, let the user download it. The user verifies the source and
   moves the file to `bios/original/` or wherever, themselves.
3. Never commit BIOS binaries (`.bin`, `.cap`, `.rom`, `.fd`, `.f*` numeric
   suffixes from Gigabyte) to git. The `.gitignore` enforces this. If you
   see a BIOS binary committed, that is a bug, surface it.
4. Never recommend bypassing DualBIOS recovery instructions. If a flash
   fails, the M_BIOS / B_BIOS recovery flow exists and should be used.
5. Multi-agent cross-validation is the default for any claim about which
   modded BIOS works on which exact board revision. Single-source claims
   from one forum post are not enough.

## Style

- No em dashes anywhere. Use double-dashes, parens, or commas.
- Casual, confident, conversational. Intelligent but not robotic.
- Don't sugar-coat. Honest pushback over reassurance.
- When something is contested or unclear, say "I don't know" or "we don't
  know yet" out loud. Don't fill the gap with plausible-sounding claims.

## Session start

```
vcd project-nvme-bios-mod
vstart
```

Then read the latest `docs/handoffs/HANDOFF_*.md`.

## Session end

```
# write a new docs/handoffs/HANDOFF_YYYY-MM-DD_<short-name>.md
vend
```
