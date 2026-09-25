# project-nvme-bios-mod

NVMe-modded BIOS and procedure for the **Gigabyte GA-970A-D3P (no S),
Revision 2.0** motherboard. Adds NVMe boot support to a board that
shipped before NVMe was a thing, so you can use a PCIe x4 NVMe adapter
as your boot drive on AM3+ hardware that would otherwise be
landfill-bound.

## If you are here because you have the same board

You probably want one of two things:

1. **The pre-built modded BIOS.**
   - File: [`bios/modded/970AD3P2_NVME.FD`](bios/modded/970AD3P2_NVME.FD)
   - SHA-256: `1dc2f8386b974ba1f3469215f0ec78381a8dcfc6d5c370d6074abd55b74483da`
   - Provenance, source BIOS, tool, module, and warnings:
     [`bios/modded/970AD3P2_NVME.FD.notes.md`](bios/modded/970AD3P2_NVME.FD.notes.md)
   - Flash procedure (verifies hash, checks Pad-files, flashes one
     chip, leaves DualBIOS backup intact):
     [`docs/runbooks/bios-mod-procedure.md`](docs/runbooks/bios-mod-procedure.md)

2. **The recipe to build it yourself.**
   The full DIY runbook is at
   [`docs/runbooks/diy-mod-procedure.md`](docs/runbooks/diy-mod-procedure.md).
   It walks the actual UEFITool steps, the Pad-file diff that is the
   real safety check, and the single-chip flash strategy.

**Read this before flashing anything.** The provenance file lists the
boards this BIOS is **not** for. The letter difference between
`GA-970A-D3P` and `GA-970A-DS3P` matters. Confirm your silkscreen.

## Status

- BIOS modded and flashed: 2026-05-07
- NVMe SSD on PCIe x4 adapter recognized as Boot Option: confirmed
- Windows 10 install on the NVMe: in progress
- DualBIOS B_BIOS chip: still on stock FC for rollback safety

See `docs/handoffs/` for the per-session log of how we got here. Sort
by date desc.

## What this repo is

Three audiences in one repo:

1. **The next person with this board.** A vetted BIOS plus a
   reproducible recipe, written from a real attempt rather than
   rephrased forum posts.
2. **Drew working on this build.** Reproducible workflow across the
   4090 desktop, 4070 Super, and Legion Go, via the standard
   `C:\dev\` session protocol.
3. **Portfolio.** A worked example of how to triangulate niche
   hardware-modding info, document tradeoffs, and build a
   reversible-by-default workflow around an irreversible-by-default
   operation.

## What this repo is NOT

- It is not a generic "how to mod any BIOS" guide. The Win-Raid main
  guide already exists and is canonical:
  <https://winraid.level1techs.com/t/howto-get-full-nvme-support-for-all-systems-with-an-ami-uefi-bios/30901>.
  We point at it, we don't replace it.
- It is not a guarantee. BIOS flashing can brick hardware. DualBIOS
  helps. It is not a free pass. Read
  [`docs/adr/0001-bios-mod-vs-bootloader-workaround.md`](docs/adr/0001-bios-mod-vs-bootloader-workaround.md)
  for the tradeoffs we considered, including the lower-risk fallback.
- It is not for the GA-970A-DS3P, GA-970A-UD3P, GA-970A-D3, or any
  other board. Use of the modded BIOS file on a different board is
  a likely brick.

## Repo layout

```
project-nvme-bios-mod/
  README.md                              you are here
  CLAUDE.md                              project-local AI instructions
  LICENSE                                MIT (covers original content)
  .gitignore                             excludes BIOS by default, with one exception
  bios/
    original/                            originals (gitignored, see README)
    modded/
      970AD3P2_NVME.FD                   the deliverable -- THE actual modded BIOS
      970AD3P2_NVME.FD.notes.md          provenance, SHA-256, hard warnings
      NEAR-MISS-2026-05-07.notes.md      project history, kept as a teaching example
      README.md                          how this directory works
  modules/
    README.md                            where NvmExpressDxe ffs files go (local-only)
  scripts/
    bootstrap-repo.ps1                   one-shot git init + commit + push
    README.md
  tools/
    README.md                            references to UEFITool / MMTool
  docs/
    adr/
      0001-bios-mod-vs-bootloader-workaround.md
    handoffs/
      template.md
      HANDOFF_2026-05-07_*.md            session-by-session state
    hardware/
      target-system.md                   board, CPU, RAM, PSU, NVMe model
      bios-settings.md                   the settings to flip in BIOS
    runbooks/
      bios-mod-procedure.md              flash a pre-built mod (covers our deliverable)
      diy-mod-procedure.md               build the mod yourself with UEFITool
      bootloader-workaround.md           lower-risk fallback (rEFInd / Clover)
```

## Quick links

- The decision record:
  [`docs/adr/0001-bios-mod-vs-bootloader-workaround.md`](docs/adr/0001-bios-mod-vs-bootloader-workaround.md)
- Target system spec:
  [`docs/hardware/target-system.md`](docs/hardware/target-system.md)
- BIOS settings to apply before any install attempt:
  [`docs/hardware/bios-settings.md`](docs/hardware/bios-settings.md)
- Latest handoff: `docs/handoffs/` sorted by date desc

## Working on this repo

This repo follows the `C:\dev\` session protocol:

```
vcd project-nvme-bios-mod
vstart
# work
vend
```

`vstart` and `vend` are defined in `C:\dev\_scripts\` and require the
device setup checklist to be complete on the current machine.

## License

MIT for the original content (docs, scripts, runbooks). See
[LICENSE](LICENSE).

The committed `970AD3P2_NVME.FD` is a derivative work built on
Gigabyte's original `FC` BIOS plus the EDK2/Clover-derived
`NvmExpressDxe_5` module compiled by the Win-Raid community member
Ethaniel. The MIT terms above do not relicense those underlying
components. Redistribution here is in the same spirit as the rest of
the BIOS-mod community: enabling continued use of obsolete hardware
that the OEM has stopped supporting. If you are the rights holder for
any underlying component and want this taken down, open an issue.
