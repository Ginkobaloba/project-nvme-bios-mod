# bootstrap-repo.ps1
#
# One-shot bootstrap for this project. Run from C:\dev\project-nvme-bios-mod
# in a regular Windows PowerShell (NOT in the AI session's bash sandbox).
#
# What it does:
#   1. Wipes any half-broken .git directory left over from earlier AI
#      session attempts (the cross-mount sandbox cannot manage .git
#      reliably; PowerShell with takeown / icacls can).
#   2. Fresh `git init -b main` and identity config.
#   3. Stages everything that isn't gitignored, shows the diff summary.
#   4. Pauses for review, then commits.
#   5. Creates the GitHub repo via `gh repo create` (public).
#   6. Pushes `main` to the new origin.
#
# Pre-conditions:
#   - You are at C:\dev\project-nvme-bios-mod
#   - `git` and `gh` are installed and on PATH (per DEVICE_SETUP.md)
#   - `gh auth status` shows you logged in to github.com as Ginkobaloba
#   - You actually want a public repo at Ginkobaloba/project-nvme-bios-mod
#
# Usage:
#   cd C:\dev\project-nvme-bios-mod
#   .\scripts\bootstrap-repo.ps1
#
# To run unattended (skip the review pause):
#   .\scripts\bootstrap-repo.ps1 -NoConfirm
#
# To skip GitHub steps (commit only, push later):
#   .\scripts\bootstrap-repo.ps1 -SkipPush

[CmdletBinding()]
param(
    [switch]$NoConfirm,
    [switch]$SkipPush,
    [string]$RepoOwner = 'Ginkobaloba',
    [string]$RepoName  = 'project-nvme-bios-mod'
)

$ErrorActionPreference = 'Stop'

function Write-Step($msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

# ----- 0. sanity ---------------------------------------------------------

if (-not (Test-Path .\README.md)) {
    Write-Error "Run this from the project root (where README.md is)."
    exit 1
}
if (-not (Test-Path .\.gitignore)) {
    Write-Error ".gitignore is missing. Aborting before any staging."
    exit 1
}

# ----- 1. wipe any partial .git ------------------------------------------

if (Test-Path .\.git) {
    Write-Step "Removing stale .git directory"
    # takeown / icacls handle the case where the AI sandbox left files
    # owned by an account PowerShell can't otherwise modify.
    takeown /F .\.git /R /D Y 2>$null | Out-Null
    icacls .\.git /grant "$($env:USERNAME):(F)" /T 2>$null | Out-Null
    Remove-Item -Recurse -Force .\.git
}

# ----- 2. fresh init -----------------------------------------------------

Write-Step "git init -b main"
git init -b main | Out-Null

git config user.email "dramattick1@gmail.com"
git config user.name  "Drew Mattick"

# ----- 3. stage and review -----------------------------------------------

Write-Step "Staging tracked files"
git add .

Write-Host ""
Write-Host "Files about to be committed:" -ForegroundColor Yellow
git status --short

Write-Host ""
Write-Host "Sanity check: any BIOS binaries staged? (should be empty)" -ForegroundColor Yellow
$leaks = git ls-files --cached |
    Where-Object { $_ -match '\.(rom|bin|cap|fd|FD|ffs|rar|7z|zip|F[0-9])([a-zA-Z]?)$' }
if ($leaks) {
    Write-Host "FAIL: BIOS-like binaries are staged:" -ForegroundColor Red
    $leaks | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Error "Aborting. Fix .gitignore or remove these files before re-running."
    exit 1
} else {
    Write-Host "  none. good." -ForegroundColor Green
}

if (-not $NoConfirm) {
    Write-Host ""
    Write-Host "Press Enter to commit, Ctrl+C to abort." -ForegroundColor Yellow
    [void](Read-Host)
}

# ----- 4. commit ---------------------------------------------------------

$commitMsg = @"
Initial scaffold for project-nvme-bios-mod

Standard C:\dev project layout (README, CLAUDE.md, .gitignore, LICENSE,
docs/handoffs, docs/adr, docs/hardware, docs/runbooks, bios/, modules/,
scripts/, tools/) for a BIOS-mod / NVMe-boot project on the Gigabyte
GA-970A-D3P (no S), Rev 2.0.

Captures the prior-session handoff verbatim. Documents a near-miss
where a DS3P (with S) modded BIOS was downloaded by mistake before the
silkscreen was re-checked and the board confirmed as D3P (no S). No
flashing happened.

ADR-0001 is Accepted with the recommendation pointing at Option 2
(rEFInd / Clover bootloader workaround), since no delivered Rev 2.0
NVMe-modded BIOS exists for the D3P (no S) on Win-Raid as of
2026-05-07.

BIOS binaries and tool binaries are gitignored. The repo commits
metadata, docs, and scripts only.
"@

Write-Step "git commit"
git commit -m $commitMsg

if ($SkipPush) {
    Write-Host ""
    Write-Host "Local commit done. Skipping GitHub steps as requested." -ForegroundColor Green
    Write-Host "When ready to push:" -ForegroundColor Yellow
    Write-Host "  gh repo create $RepoOwner/$RepoName --public --source=. --remote=origin"
    Write-Host "  git push -u origin main"
    exit 0
}

# ----- 5. gh auth check --------------------------------------------------

Write-Step "Verifying gh CLI auth"
$ghCheck = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host $ghCheck -ForegroundColor Yellow
    Write-Error "gh CLI not authenticated. Run 'gh auth login' and re-run this script with -SkipPush=$false."
    exit 1
}
Write-Host $ghCheck

# ----- 6. create remote and push -----------------------------------------
#
# Note on PowerShell + native commands + $ErrorActionPreference='Stop':
# When `gh repo view` returns a non-zero exit (which is the normal "repo
# does not exist yet" path), PowerShell's strict ErrorAction can treat
# the native stderr as a terminating error and bail before we reach the
# `else` branch. We swallow it explicitly here to keep the flow.

Write-Step "Checking whether $RepoOwner/$RepoName already exists"

$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$null = & gh repo view "$RepoOwner/$RepoName" 2>&1
$repoExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $prevEAP

if ($repoExists) {
    Write-Host "Repo already exists at github.com/$RepoOwner/$RepoName. Linking existing remote." -ForegroundColor Yellow
    $remoteUrl = "https://github.com/$RepoOwner/$RepoName.git"
    git remote remove origin 2>$null
    git remote add origin $remoteUrl
} else {
    Write-Step "Creating GitHub repo $RepoOwner/$RepoName (public)"
    gh repo create "$RepoOwner/$RepoName" --public --source=. --remote=origin --description "Adding NVMe boot support to a Gigabyte GA-970A-D3P Rev 2.0 motherboard. Project scaffold, decision records, and runbooks."
    if ($LASTEXITCODE -ne 0) {
        Write-Error "gh repo create failed (exit $LASTEXITCODE). Inspect the message above and re-run, or finish manually with: gh repo create $RepoOwner/$RepoName --public --source=. --remote=origin ; git push -u origin main"
        exit 1
    }
}

Write-Step "git push -u origin main"
git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Write-Error "git push failed (exit $LASTEXITCODE)."
    exit 1
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "  Local:   $(Get-Location)" -ForegroundColor Green
Write-Host "  Remote:  https://github.com/$RepoOwner/$RepoName" -ForegroundColor Green
