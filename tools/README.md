# tools/

Reference-only directory for third-party utilities used in the BIOS mod
workflow. The binaries themselves are gitignored. Each utility gets a
`<tool>.notes.md` capturing where to download it and how to verify it.

## Utilities used

### AMI Aptio MMTool

The easiest tool for inserting a module into an AMI Aptio IV BIOS.

- Recommended versions: `4.50.0.23` (primary) or `5.0.0.7` (fallback).
- Not freely redistributable. Search "MMTool Aptio 4.50.0023" or
  "MMTool Aptio 5.00.0007" on TweakTown's BIOS tools page.
- Live in `tools/MMTool*` once downloaded. Do not commit.

### UEFITool

Open-source UEFI editor. Good for visual inspection and for cases where
MMTool refuses to insert a module.

- Use **classic** UEFITool (NOT UEFITool_NE), version `0.28.0` per the
  Win-Raid guide.
- Source: download link in the Win-Raid main NVMe guide.
- Live in `tools/UEFITool*` once downloaded. Do not commit.

### Rufus

For making the bootable Windows install USB.

- Use the latest stable from <https://rufus.ie>.
- Settings for this target: GPT, UEFI (non CSM), NTFS if the install.wim
  is over 4 GB (which it now is for current Win10/11 ISOs).

### `bcdedit`, `efibootmgr` (Linux), or rEFInd installer

For Option 2 (the bootloader workaround). Plain Windows tooling for
`bcdedit`. rEFInd has its own installer scripts. Clover lives in its own
repo.
