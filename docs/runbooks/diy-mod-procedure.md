# Runbook: DIY BIOS Mod Procedure (what was actually done)

This is the runbook based on the path actually taken on 2026-05-07. The
older `bios-mod-procedure.md` was written speculatively, before we knew
whether anyone had a delivered BIOS for this board. It still works for
the case where someone hands you a pre-modded BIOS. This runbook is for
the case where there is no community-modded BIOS for your exact board
and you have to make one yourself.

If your board is the **Gigabyte GA-970A-D3P (no S), Rev 2.0** and you
are happy to flash a hash-verified pre-built file rather than make your
own from scratch: skip this runbook and use
`bios/modded/970AD3P2_NVME.FD` directly per
`bios-mod-procedure.md`. Verify the SHA-256 first.

If you have a different board: this runbook gets you 90% of the way,
but the specifics (filenames, BIOS version, exact volume layout) need
to be re-derived for your hardware.

## Pre-conditions

- You have already confirmed the exact board model and revision via PCB
  silkscreen, in writing, with a photo, and matched it against
  Gigabyte's product page. **No exceptions.**
- You have read the Win-Raid main NVMe guide once end-to-end:
  <https://winraid.level1techs.com/t/howto-get-full-nvme-support-for-all-systems-with-an-ami-uefi-bios/30901>
- You accept that BIOS flashing is hardware-irreversible. DualBIOS
  helps. It is not a free pass.

## Tools you will download yourself

The repo does not commit either of these for licensing reasons.

- **UEFITool**, the classic version `0.28.0` (NOT UEFITool_NE).
  Source: download link in the Win-Raid main NVMe guide above.
- **NvmExpressDxe_5.ffs**, the full variant module compiled by
  Ethaniel from EDK2/Clover sources.
  Source: download link in the same Win-Raid guide. There is also a
  Small variant for boards with cramped DXE volumes; D3P Rev 2.0 has
  enough room for the full one.

## Steps

### 1. Get the original BIOS

From <https://www.gigabyte.com/Motherboard/GA-970A-D3P-rev-2x/support>
download BIOS version `FC` dated 2015-06-01. This is the latest
official version for the Rev 2.x board. Save it to
`C:\dev\project-nvme-bios-mod\bios\original\` (the local-only copy,
gitignored).

The download is a `.zip` containing the BIOS file and Gigabyte's
`autoexec.bat` for DOS flashing. We only need the BIOS file (the
extension is bare, like `.FC` or `970AD3P2.FC`).

### 2. Compute and record the SHA-256 of the original

```powershell
Get-FileHash -Algorithm SHA256 .\bios\original\970AD3P2.FC
```

Capture the hash in
`bios/original/970AD3P2.FC.notes.md` so future-you can verify the
file you started from has not changed.

### 3. Open both files in UEFITool

You will work with two windows side by side:

- Window A: the original BIOS (read-only reference)
- Window B: a working copy you will modify

Copy `970AD3P2.FC` to a working location (e.g.
`bios/modded/970AD3P2.FC.working`) so the original stays untouched.
Open it in window B.

### 4. Find the target DXE Driver Volume

In window B, hit Ctrl+F (or File > Search), pick the Text tab, type
`CSMCORE`, hit OK. Double-click any match in the Messages pane at the
bottom. UEFITool will jump to the CSMCORE module. Collapse one level
up and you are now inside the DXE Driver Volume. This is where the
NVMe module goes.

### 5. Insert NvmExpressDxe_5

Scroll to the bottom of the modules list inside that volume. The very
last entry of subtype `DXE driver` or `Freeform` (whichever shows up
last) is your insertion target. On D3P Rev 2.0 the bottom module
varies a bit by where you click, but anywhere near the bottom of the
DXE volume is fine because UEFITool will keep ordering consistent.

Right-click the bottom DXE driver, pick `Insert after...`, navigate
to your downloaded `NvmExpressDxe_5.ffs`, double-click. Verify the
new module appears. Save with Ctrl+S, name it
`970AD3P2_NVME.FD`, click Yes when UEFITool offers to reopen the
reconstructed file.

### 6. Pad-file diff: the gate that prevents bricks

This is the step that gets skipped most often and the step that
matters most. Open the original BIOS in window A again. Open the
just-saved modded BIOS in window B. Side by side, expand the DXE
Driver Volume in both. Walk the entire module list top to bottom.

Acceptable difference: window B has one new module
(`NvmExpressDxe_5`) that window A does not. That is it.

Unacceptable differences include any of:

- A Pad-file present in window A is missing in window B
- A Pad-file present in window B is missing in window A
- Modules appear in different order
- Module sizes have changed for anything other than the new module

If you see any unacceptable difference, **stop**. Re-do the insertion
with a fresh copy of the original. If it happens again, post the diff
and your BIOS version into the relevant Win-Raid thread and ask. The
Pad-file structure encodes BIOS volume layout that the firmware
relies on, and corrupting it during a "successful" UEFITool save is
the most common cause of bricked boards from this procedure.

### 7. Flash one chip, leave the other

Format a USB 2.0 stick FAT32, copy `970AD3P2_NVME.FD` to its root,
nothing else.

Reboot the board, hit F2 (or DEL) into BIOS. F8 launches Q-Flash.
Pick `Update Main BIOS from Drive`, pick the USB stick, pick the
modded file. Confirm.

The flash takes a few minutes. Do not power off, do not touch
anything. After it completes, the board reboots automatically.

**Do not flash B_BIOS yet.** B_BIOS stays on the original, unmodified
`FC` BIOS. If something is wrong with the modded one, the board can
fall back to B_BIOS automatically and you can re-flash from there.
If both chips are modded and both chips have the same problem, that
fallback no longer exists.

### 8. Verify

Reboot, into BIOS. Re-apply the BIOS settings from
`docs/hardware/bios-settings.md` (UEFI Only, no CSM, Secure Boot off,
OS Type Win 8/10 WHQL, Storage Boot Option Control UEFI Only). Some
of those revert across a flash.

In the Boot section, check Boot Priority. The NVMe SSD's `Windows
Boot Manager` entry will not exist yet (no OS on the NVMe) but the
NVMe drive itself should appear as a selectable boot device. If it
does, the mod worked. Proceed to install Windows per
`bootloader-workaround.md`'s "Steps for installing Windows" section
(the install part of that runbook applies regardless of which boot
path you took).

If the NVMe does not appear as a Boot Option after the flash:

- Confirm the modded BIOS actually got written. Some Q-Flash
  failures are silent. Re-enter Q-Flash, you may see a "BIOS version"
  field that shows the running version.
- Check whether the system booted from M_BIOS or fell back to
  B_BIOS. Gigabyte BIOSes show this in System Info usually.
- If it fell back to B_BIOS, the mod failed. Try the procedure
  again with a fresh copy of the original BIOS, paying special
  attention to step 6.

### 9. Stable for a few power cycles? Optionally flash B_BIOS

Recommendation: do not. A backup BIOS that matches the main BIOS is
not a backup, it is a duplicate. Leave B_BIOS on stock `FC` so you
can always recover.

Only flash B_BIOS if you have a specific reason and you are accepting
the loss of the rollback safety net.

## Rollback

To return the board to the original `FC` BIOS:

1. Re-download `FC` from gigabyte.com.
2. Q-Flash it onto M_BIOS using the same procedure above.
3. The NVMe will disappear from Boot Options, confirming the revert.
4. If you still need NVMe boot, install rEFInd per
   `bootloader-workaround.md`.

## Why we chose this path over Option 2 for this specific board

Originally ADR-0001 recommended Option 2 (rEFInd or Clover bootloader)
because no delivered Rev 2.0 mod existed for the D3P (no S) on
Win-Raid. The DIY version of Option 1 that this runbook describes is
what you actually do when:

- You are comfortable with UEFITool
- You will not skip the Pad-file diff in step 6
- You have a clean rollback strategy (single chip flashed, B_BIOS
  intact)
- You accept hardware-irreversible operations

If any of those is not true, Option 2 is still the safer answer.
