# scripts/

Project-local scripts. Mostly verification helpers that are safer to run
than to memorize.

Planned scripts (not yet written):

- `verify-bios-checksum.ps1` -- given a BIOS file path and an expected
  SHA-256, verify the match and refuse to proceed if it doesn't.
- `compare-bios-volumes.ps1` -- given an original and a modded BIOS, dump
  the DXE Driver Volume contents from both and diff them. The only
  expected difference should be the addition of the NvmExpressDxe module.
  Anything else is a red flag and a likely brick.
- `prepare-flash-stick.ps1` -- formats a USB stick FAT32 and copies the
  modded BIOS to the root with the exact filename Q-Flash expects.

These will be written as we actually need them, with the actual filenames
and quirks of the target board, rather than speculatively.
