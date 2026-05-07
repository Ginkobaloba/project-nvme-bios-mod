# bios/

Local-only directory for BIOS binaries. **Nothing in `bios/original/` or
`bios/modded/` is committed to git.** The `.gitignore` enforces this.

## Why we don't commit BIOS files

1. **Copyright.** The unmodified Gigabyte BIOS is Gigabyte's IP. The Win-Raid
   community-modded BIOS is the modder's work product, distributed by them
   under their terms on the Win-Raid forum. Neither is ours to redistribute.
2. **Bricks.** A wrong BIOS file in the wrong directory is a flashing
   accident waiting to happen. Treating these files as never-shared keeps
   the blast radius local.
3. **Repo size.** BIOS images are 4 to 16 MB and we don't need them in git
   history.

## What goes here

```
bios/
  original/    Original Gigabyte BIOSes downloaded from gigabyte.com
  modded/      Win-Raid community-modded BIOSes downloaded from Win-Raid
```

For each file, also write a sibling `<filename>.notes.md` that captures:

- **Source URL** (where you downloaded it)
- **SHA-256** of the file
- **Date** you downloaded it
- **Board** and **revision** the file is intended for, exactly as stated
  on the source page
- **Forum thread** with the discussion of who tested it and on what

The `.notes.md` files are not gitignored. They are the bread crumbs that
let us reconstruct what we used, even though we can't redistribute the
files themselves.

## How to compute SHA-256 on Windows

```powershell
Get-FileHash -Algorithm SHA256 .\bios\original\970AD3P.FC
```

## Recovery

If a flash bricks the board, the GA-970A series has DualBIOS:

- Power off, hold the power button to drain.
- Power back on, the corrupt BIOS triggers fallback to the backup BIOS.
- Re-flash from the recovered BIOS to the failed BIOS chip.

This is a safety net, not a guarantee. Some scenarios (both chips flashed
to a wrong-revision modded BIOS) defeat DualBIOS.
