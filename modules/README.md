# modules/

Reference-only directory for the EFI NVMe driver modules that get inserted
into the BIOS DXE Driver Volume. Same rules as `bios/`: we don't commit the
binaries themselves, we commit the metadata.

## What goes here

The Win-Raid community maintains two NvmExpressDxe variants:

| File | Size | When to use |
|---|---|---|
| `NvmExpressDxe_5.ffs` | ~18 KB uncompressed | Default. More features, broader NVMe SSD compatibility. |
| `NvmExpressDxe_Small.ffs` | ~6 KB uncompressed | Use when the BIOS has a small DXE Driver Volume and the regular module won't fit. |

Both are compiled from EDK2/Clover sources by the Win-Raid community member
Ethaniel.

## Source

The canonical download links are in the Win-Raid main guide at:
<https://winraid.level1techs.com/t/howto-get-full-nvme-support-for-all-systems-with-an-ami-uefi-bios/30901>

Always download from there, not from third-party mirrors. Verify SHA-256.

## Notes file format

For each module copied locally:

```
<filename>.notes.md   <- not gitignored, capture provenance here
<filename>.ffs        <- gitignored
```

`.notes.md` should contain source URL, SHA-256, date, intended use, and
the BIOS volume sizing logic for why this variant was chosen.
