# HANDOFF_2026-05-07_d3p-confirmed-pivot-to-option-2

## What this session did

- **Resolved the board identity.** Drew re-checked the silkscreen and
  confirmed the board has **no `S`** in the model. Board is
  **GA-970A-D3P, Revision 2.0**, not DS3P.
- **Caught and avoided a near-miss.** A DS3P Rev 2.x modded BIOS had
  been downloaded into `bios/modded/` based on the wrong reading. Drew
  deleted the wrong BIOS files manually. Nothing was flashed.
- **Updated the docs to reflect the confirmation:**
  - `docs/hardware/target-system.md` -- board identity locked in,
    open question for D3P-vs-DS3P closed.
  - `CLAUDE.md` -- ambiguity warning replaced with confirmed identity
    and the implication for the BIOS-mod path.
  - `docs/adr/0001-bios-mod-vs-bootloader-workaround.md` -- status
    moved from "Proposed" to "Accepted." Recommendation is **Option 2
    (rEFInd / Clover bootloader workaround)**, because no delivered
    Rev 2.0 mod exists on Win-Raid for the D3P (no S).
- **Captured the near-miss as project history.** Created
  `bios/modded/NEAR-MISS-2026-05-07.notes.md` with the lessons.
- **Confirmed via a second WebSearch pass** that the Win-Raid D3P thread
  sits in `BIOS Modding Requests`, not in `Offers: Already modded
  special BIOSes`, which is the structural signal that no delivered
  mod exists for our exact board there.

## What is currently broken or incomplete

- A residual `WRONG-BOARD-DO-NOT-FLASH.notes.md` and an empty
  `.quarantine-wrong-board/` directory remain in `bios/modded/`. The
  cross-mount sandbox couldn't unlink them. They're now self-explaining
  history files but can be removed with one PowerShell command (see
  the file's own contents).
- Git repo is still not initialized for the second time. Drew's
  message asked for the commit and push to be done. Whether the AI
  session was able to complete that or had to fall back to the
  PowerShell bootstrap script is captured in the next handoff.
- No GitHub remote yet. Will be `Ginkobaloba/project-nvme-bios-mod`.

## What the next session should do first

1. Apply the BIOS settings changes in
   `docs/hardware/bios-settings.md` on Mark's PC. Reboot, verify they
   stuck. These are the single highest-value action available right
   now and almost certainly fix the 0x8007025D installer errors on
   their own.
2. Reinstall Windows 10 onto the NVMe SSD with the settings now sane
   (UEFI Only, no CSM, Secure Boot off, Storage Boot to UEFI Only,
   OS Type Windows 8/10 WHQL).
3. Do not attempt to boot from the NVMe yet. The BIOS still cannot
   enumerate it as a boot device.
4. Install rEFInd onto a small EFI partition on the existing SATA
   HDD per `docs/runbooks/bootloader-workaround.md`. Configure it to
   default-boot the NVMe Windows entry.
5. After step 4, the system should boot Windows from the NVMe via
   the rEFInd chainload on every power-on with no manual steps.
6. Once that's working, capture exact CPU model, NVMe SSD model,
   and PSU wattage in `docs/hardware/target-system.md`.

## Open questions for Drew

- Are you OK committing to Option 2 as the path forward, or do you
  want to also post in the Win-Raid D3P request thread (with the
  original FC BIOS file) to see if a delivered mod can be coaxed out
  as a parallel track?
- Repo visibility: still public on `Ginkobaloba/project-nvme-bios-mod`?
- Are you OK with me opening a follow-up agent later that drives the
  rEFInd installation runbook to completion as actual tested-on-the-box
  steps (vs. the current generic version)?

## Pointers

- ADR (now Accepted, Option 2):
  `docs/adr/0001-bios-mod-vs-bootloader-workaround.md`
- Path-forward runbook: `docs/runbooks/bootloader-workaround.md`
- Pre-install BIOS setting changes: `docs/hardware/bios-settings.md`
- Near-miss history: `bios/modded/NEAR-MISS-2026-05-07.notes.md`
- Win-Raid request thread for D3P (no S):
  <https://winraid.level1techs.com/t/mod-bios-for-gigabyte-ga-970a-d3p/35457>
- Win-Raid Clover-EFI bootloader fallback method (background reading):
  <https://winraid.level1techs.com/t2375f25-Guide-NVMe-boot-without-modding-your-UEFI-BIOS-Clover-EFI-bootloader-method.html>

## Next Session Onboarding

> Future sessions: read `C:\dev\SESSION_PROTOCOL.md`, then `CLAUDE.md` in
> this project, then this file, then run `vstart`.
