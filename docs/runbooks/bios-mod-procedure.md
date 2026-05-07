# Runbook: BIOS Mod Procedure (Option 1)

**Pre-conditions:**

- Board model and revision are CONFIRMED in writing in the latest handoff
  doc, with a silkscreen photo as evidence.
- A Rev 2.0-specific modded BIOS exists for the exact submodel, in a
  Win-Raid thread with multiple successful flash reports we have read.
- The BIOS settings changes in `docs/hardware/bios-settings.md` have been
  applied and verified.
- Mark has been told what could go wrong, including the brick scenario.

If any of these is not true, do not proceed. Use Option 2 instead.

## What we're doing, in plain English

The board's UEFI firmware is missing a piece of code that knows how to
talk to NVMe drives during boot. The Win-Raid community has compiled
that piece of code (`NvmExpressDxe_5.ffs` or `NvmExpressDxe_Small.ffs`)
and inserted it into a copy of the original Gigabyte BIOS. We're going
to flash that modded BIOS into the board's M_BIOS chip using Gigabyte's
Q-Flash utility. The B_BIOS chip stays on the original BIOS as a safety
net in case the modded one is bad.

## Tools required

- A blank FAT32-formatted USB 2.0 stick
- The modded BIOS file from Win-Raid (downloaded by the user, not by AI)
- The original BIOS file from gigabyte.com (as the safety baseline)
- SHA-256 hashes from the Win-Raid thread to verify the modded file
  hasn't been corrupted in transit

## Steps

### 1. Verify the modded BIOS file

```powershell
Get-FileHash -Algorithm SHA256 .\bios\modded\<modded-filename>
```

Compare against the SHA-256 posted in the Win-Raid thread. **If they do
not match, stop. Re-download from the Win-Raid post directly. Do not
proceed.**

### 2. Compare the modded BIOS against the original

Open both files in UEFITool side by side. Navigate to the DXE Driver
Volume (the volume that contains the `CSMCORE` module). Confirm:

- The modded BIOS has exactly one new module, named either
  `NvmExpressDxe_5` or `NvmExpressDxe_Small`, that the original does not.
- No other modules in the DXE Driver Volume have been added, removed, or
  reordered.
- No "Pad-files" have been added or removed compared to the original.

If anything else is different, stop. Post in the Win-Raid thread and
ask. The Win-Raid main guide explicitly warns that some MMTool / UEFITool
versions will silently rearrange Pad-files in a way that bricks the
flash. The visual diff is the only safety check.

### 3. Prepare the flash USB

Format a USB 2.0 stick (USB 3.0 sticks are sometimes flaky for Q-Flash):

```powershell
# Use Disk Management or:
Format-Volume -DriveLetter <letter> -FileSystem FAT32 -Confirm:$false
```

Copy the modded BIOS file to the root of the stick. Just the BIOS file,
nothing else. Use the exact filename Q-Flash expects (usually matches
the original Gigabyte BIOS naming, e.g. `970AD3P.FC` or similar).

### 4. Power down clean

- Shut Windows down (if running).
- Disconnect the NVMe adapter card and any USB devices except the BIOS
  flash stick. Less to fight with during recovery if it goes wrong.
- Leave the GPU and one stick of RAM in.

### 5. Boot to BIOS, launch Q-Flash

- Power on, F2 (or DEL) into BIOS.
- F8 launches Q-Flash on Gigabyte boards.
- Choose "Update Main BIOS from Drive."
- Pick the FAT32 USB stick.
- Pick the modded BIOS file.
- Confirm.

### 6. Wait

The flash takes a couple of minutes. Do not power off, do not bump the
machine. The screen may briefly show progress in a basic font.

### 7. Reboot, confirm

- After the flash completes, reboot.
- F2 / DEL back into BIOS.
- Re-apply the BIOS settings from `docs/hardware/bios-settings.md` (some
  may have reverted).
- Reconnect the NVMe adapter.
- Reboot once more.
- Verify the NVMe is now visible under Boot Option #1.

### 8. If the system does not POST

- Power off.
- Hold the power button to drain.
- Power back on. The board's DualBIOS should detect the failure and
  switch to B_BIOS (the unmodified backup).
- Once POSTing again, do **not** re-flash anything yet. Verify B_BIOS is
  active (Gigabyte BIOS shows which chip is currently booted somewhere
  in the System Info page). Decide whether to retry the flash or pivot
  to Option 2.

### 9. Once stable on the modded M_BIOS, decide on B_BIOS

You have two choices:

- **Leave B_BIOS on the original unmodified BIOS** as a permanent safety
  net. The board boots from M_BIOS in normal operation, B_BIOS is your
  emergency rollback.
- **Flash B_BIOS to the same modded image** so both chips are NVMe-aware.
  This loses the rollback safety net.

Recommendation: leave B_BIOS unmodified. A backup BIOS that matches
M_BIOS is just a duplicate, not a backup.

## Rollback

If you decide later that the modded BIOS is causing problems and you
want to go back:

1. Download the latest **original** Gigabyte BIOS for the exact
   board+revision from gigabyte.com.
2. Q-Flash the original onto M_BIOS using the same procedure above.
3. Verify NVMe is no longer in Boot Option #1 (proof you really
   reverted).
4. If the NVMe install needs to keep working, switch to Option 2
   (bootloader workaround) at this point.

## Don't

- Don't flash B_BIOS until M_BIOS is confirmed stable for at least a
  few power cycles.
- Don't flash from inside Windows. Q-Flash from BIOS is the supported
  path.
- Don't use a USB 3.0 hub. Use the back-panel USB 2.0 ports directly.
