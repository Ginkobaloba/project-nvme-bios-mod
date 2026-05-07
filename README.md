# project-nvme-bios-mod

Adding NVMe boot support to motherboards that shipped before NVMe was a thing.
Specifically: AMI Aptio UEFI boards where the original BIOS doesn't know how to
boot from an NVMe SSD on a PCIe x4 adapter, and we want to fix that.

The first target is a **Gigabyte GA-970A series board, Revision 2.0**, AM3+,
AMD 970 chipset, BIOS version FC dated 2015-06-01. There is an open question
on the exact submodel (D3P vs DS3P) that has to be resolved before any flashing
happens. See `docs/hardware/target-system.md` and
`docs/adr/0001-bios-mod-vs-bootloader-workaround.md`.

## Status

Pre-flight. No flashing has happened. The repo is currently:

- Hardware spec captured
- BIOS settings to change captured
- Two-path decision (mod the BIOS, or chainload from a SATA bootloader)
  documented
- Critical open question about board submodel flagged

## What this repo is for

Three audiences in one repo:

1. **Drew working on Mark's PC.** Make the actual install work, without
   bricking the board. Every step has to be reproducible across sessions on
   different machines (4090 desktop, 4070 Super, Legion Go).
2. **Anyone else with the same Gigabyte 970-series board.** Worked example of
   the BIOS-mod path and the bootloader-workaround path, with the gotchas
   documented from real attempts rather than generic forum hearsay.
3. **Portfolio.** A concrete example of how to triangulate niche
   hardware-modding info, document tradeoffs honestly, and build a
   reversible-by-default workflow around an irreversible-by-default operation.

## What this repo is NOT for

- It is not a place to host copyrighted Gigabyte BIOS binaries or the Win-Raid
  community's modded BIOS files. Those stay on the source forums. We commit
  metadata, scripts, and documentation. See `bios/README.md`.
- It is not a generic "how to mod any BIOS" guide. The Win-Raid guide already
  exists for that. We point at it, don't replace it.
- It is not a guarantee. BIOS flashing can brick hardware. DualBIOS helps, but
  is not a free pass.

## Repo layout

```
project-nvme-bios-mod/
  README.md                           you are here
  CLAUDE.md                           project-local AI instructions
  LICENSE                             MIT
  .gitignore                          excludes BIOS binaries and session log
  bios/
    original/                         original Gigabyte BIOS (gitignored, see README)
    modded/                           modded BIOSes (gitignored, see README)
    README.md                         what goes here, why we don't commit binaries
  modules/
    README.md                         where the NvmExpressDxe ffs files go
  scripts/                            session and verification scripts
    README.md
  tools/                              checksums, links to MMTool, UEFITool
    README.md
  docs/
    adr/
      0001-bios-mod-vs-bootloader-workaround.md
    handoffs/
      template.md                     seed for new handoff docs
      HANDOFF_2026-05-07_*.md         per-session state
    hardware/
      target-system.md                Mark's PC hardware spec
      bios-settings.md                the settings to flip before flashing
    runbooks/
      bios-mod-procedure.md           Option 1 if confirmed Rev 2.0 mod exists
      bootloader-workaround.md        Option 2 fallback (Clover or rEFInd)
```

## Quick links

- The decision record: [`docs/adr/0001-bios-mod-vs-bootloader-workaround.md`](docs/adr/0001-bios-mod-vs-bootloader-workaround.md)
- Target system spec: [`docs/hardware/target-system.md`](docs/hardware/target-system.md)
- BIOS settings to change first: [`docs/hardware/bios-settings.md`](docs/hardware/bios-settings.md)
- Latest handoff: `docs/handoffs/` (sort by date desc)

## Working on this repo

This repo follows the `C:\dev\` session protocol:

```
vcd project-nvme-bios-mod
vstart
# work
vend
```

`vstart` and `vend` are defined in `C:\dev\_scripts\` and require the
[device setup checklist](../DEVICE_SETUP.md) to be complete on the current
machine. See [`C:\dev\SESSION_PROTOCOL.md`](../SESSION_PROTOCOL.md) for the
full lifecycle.

## License

MIT. See [LICENSE](LICENSE). Note that "MIT" applies to the original content
in this repo (docs, scripts, schema). It does not relicense Gigabyte BIOS
binaries, AMI MMTool, or any third-party module dropped into `modules/` or
`bios/`. Those carry their own licenses, which is the main reason we don't
commit them.
