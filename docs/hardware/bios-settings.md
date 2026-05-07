# BIOS Settings to Change Before Any Further Install Attempt

These changes are independent of the NVMe boot question. They fix the
hybrid Legacy/UEFI mess that is most likely contributing to the 0x8007025D
errors, and they are required for a clean UEFI install regardless of
whether we end up modding the BIOS or chainloading from a SATA bootloader.

**Apply these even if we end up choosing Option 2 (bootloader workaround).**

## Path: Gigabyte BIOS, "BIOS Features" tab

| Setting | Change from | Change to | Reason |
|---|---|---|---|
| OS Type | Other OS | Windows 8/10 WHQL | Tells the BIOS to use Microsoft's UEFI signing keys for Secure Boot logic. |
| Boot Mode Selection | (Legacy or Auto) | UEFI Only | Force a clean UEFI boot. Avoids the hybrid mode. |
| Storage Boot Option Control | Legacy | UEFI Only | Same reason. The current Legacy setting is a likely contributor to install failures. |
| Secure Boot | (Enabled) | Disabled | The Microsoft Win10 ISO from before the BlackLotus bootloader revocation is flagged by Rufus as containing a "revoked UEFI bootloader." Disabling Secure Boot is the documented workaround. This is normal, not malware. |
| CSM (Compatibility Support Module) | Enabled | Disabled | We do not need legacy ROMs. Disabling CSM is required for clean UEFI mode and is one of the conditions stated in the Win-Raid guide. Note: requires a UEFI-capable graphics adapter, which the Sapphire GPU should be on this generation. |

## After these changes, before the next install attempt

1. Save BIOS, reboot.
2. Re-enter BIOS, confirm the changes stuck (Gigabyte's BIOS has been
   known to revert some settings if they conflict).
3. Confirm the NVMe SSD's adapter card is visible in `Peripherals` or
   under PCIe slot info. If it isn't, the BIOS isn't enumerating the
   adapter at all, and that is a separate problem.
4. Confirm the existing SATA HDD is still listed. We want to be able to
   keep / repurpose it.

## What you will NOT see after these changes (yet)

You will still not see the NVMe SSD listed under Boot Option #1. That is
the actual problem this project is solving. Don't be alarmed; the BIOS
not knowing how to boot from NVMe is the whole reason we're here.

## After the BIOS-mod or bootloader-workaround is in place

After Option 1 (BIOS mod) succeeds:

- The NVMe SSD's "Windows Boot Manager" entry should appear in the boot
  device list.
- If you temporarily re-enable CSM and Legacy, the NVMe should also show
  as `PATA` or `PATA_SS` (this is the Win-Raid verification trick from
  the main guide). Don't try to actually boot off `PATA` -- it will not
  work without an Option ROM in the SSD.

After Option 2 (bootloader workaround) succeeds:

- Boot Option #1 will be the SATA drive that hosts the rEFInd or Clover
  EFI partition.
- The bootloader picks up the NVMe Windows install and chainloads it.

## Reverting

If anything in this project goes sideways, the BIOS settings can all be
reverted from the BIOS itself. Only the actual BIOS flash is irreversible
(modulo DualBIOS recovery).
