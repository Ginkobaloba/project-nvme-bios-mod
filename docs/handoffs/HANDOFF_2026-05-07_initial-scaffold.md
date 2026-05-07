# HANDOFF_2026-05-07_initial-scaffold

## What this session did

- Stood up `C:\dev\project-nvme-bios-mod` following the standard `C:\dev\`
  session protocol and naming conventions.
- Captured the prior-session handoff (BIOS Mod & Windows Install on
  Gigabyte GA-970A-D3P Rev 2.0) as the seed context.
- Wrote the README, CLAUDE.md, .gitignore, LICENSE, and per-directory
  README files for `bios/`, `modules/`, `scripts/`, `tools/`.
- Wrote the hardware specification (`docs/hardware/target-system.md`)
  and the BIOS settings to change before any further install attempt
  (`docs/hardware/bios-settings.md`).
- Wrote ADR-0001 capturing the BIOS-mod vs. bootloader-workaround
  decision, with the silkscreen confirmation as the gating open question.
- Wrote runbooks for both Option 1 (`bios-mod-procedure.md`) and Option 2
  (`bootloader-workaround.md`) so whichever path we choose has a
  reproducible procedure.
- Confirmed via WebSearch that:
  - A Rev 2.x NVMe mod for **GA-970A-DS3P** (with S) exists on Win-Raid
    with reports of successful flashes.
  - For **GA-970A-D3P** (no S) Rev 2.x there is a request thread but we
    have not verified a delivered, multi-user-confirmed mod.
- Initialized the project directory but did not yet `git init`. That is
  the next session's first action.

## What is currently broken or incomplete

- The board submodel is still ambiguous. Handoff says D3P. Earlier
  verbal answer said DS3P. **Resolution requires a clear photo of the
  PCB silkscreen.**
- The cross-validation agent that was supposed to independently confirm
  the Rev 2.0 mod existence errored out at start due to a tool-schema
  issue. The WebSearch results are the only confirmation we have, and
  they're decent but not the second source the user's preferences
  call for.
- Git has not yet been initialized. Repo is staged on disk only.
- No GitHub remote yet. Naming convention says it will be
  `Ginkobaloba/project-nvme-bios-mod` when the user creates it.
- BIOS settings have not been changed on Mark's PC yet. They should be,
  before any other install attempt, regardless of which path we end up
  choosing.

## What the next session should do first

1. Confirm the silkscreen reading. Have Drew (or Mark) take a clear
   photo of the area near the AM3+ socket showing `GA-970A-...-rev`.
   Update `docs/hardware/target-system.md` with the result and remove
   the ambiguity warning.
2. Apply the BIOS settings from `docs/hardware/bios-settings.md` on
   Mark's PC. Reboot. Verify the changes stuck. Document any settings
   that wouldn't change or reverted, in a new handoff doc.
3. If silkscreen shows DS3P: open the Win-Raid Rev 2.x DS3P thread,
   read the latest pages of replies, and capture the exact filename
   and SHA-256 of the recommended modded BIOS into a notes file under
   `bios/modded/`.
4. If silkscreen shows D3P: check the Win-Raid request thread
   <https://winraid.level1techs.com/t/mod-bios-for-gigabyte-ga-970a-d3p/35457>
   to see whether a delivered Rev 2.0 mod has been posted. If yes, same
   process as DS3P. If no, pivot to Option 2.
5. Run a second-source agent (e.g. via the Plan agent or general-purpose
   agent) to independently triangulate the modded-BIOS findings. The
   user explicitly prefers multi-agent cross-validation for niche
   forum-based info, and the first attempt errored.
6. Run `git init`, make the first commit (with the scaffold and these
   handoffs), and create the GitHub remote.

## Open questions for Drew

- Silkscreen confirmation: D3P or DS3P?
- Exact CPU model on this board (FX-8350? 8320? 6300?)
- PSU wattage from the label
- Which NVMe SSD model is in the adapter (this also affects whether the
  Small NvmExpressDxe variant might be needed)
- Has Mark confirmed the existing HDD has nothing important on it?
- Repo visibility: do you want me to create the GitHub remote in a future
  session via `gh repo create`, or do you prefer to create it manually
  the first time?

## Pointers

- Win-Raid main NVMe mod guide:
  <https://winraid.level1techs.com/t/howto-get-full-nvme-support-for-all-systems-with-an-ami-uefi-bios/30901>
- DS3P Rev 2.x mod offer thread:
  <https://winraid.level1techs.com/t/offer-gigabyte-ga-970a-ds3p-rev2-x-bios-mod-nvme-added/32023>
- D3P (no S) request thread:
  <https://winraid.level1techs.com/t/mod-bios-for-gigabyte-ga-970a-d3p/35457>
- Clover-EFI bootloader method (fallback path):
  <https://winraid.level1techs.com/t2375f25-Guide-NVMe-boot-without-modding-your-UEFI-BIOS-Clover-EFI-bootloader-method.html>
- Local files of immediate interest:
  - `docs/hardware/target-system.md`
  - `docs/hardware/bios-settings.md`
  - `docs/adr/0001-bios-mod-vs-bootloader-workaround.md`
  - `docs/runbooks/bios-mod-procedure.md`
  - `docs/runbooks/bootloader-workaround.md`

## Next Session Onboarding

> Future sessions: read `C:\dev\SESSION_PROTOCOL.md`, then `CLAUDE.md` in
> this project, then this file, then run `vstart`.
