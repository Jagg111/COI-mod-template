# spawn.ps1 - copies the launchpad template/ into a target folder, applies
# placeholder substitutions to file names AND contents, and normalizes file
# encoding to UTF-8 (no BOM) with CRLF line endings.
#
# Called by the /kickoff skill after it has gathered all the user's answers.
# Can also be run directly for testing - pass values via parameters.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $LaunchpadPath,
    [Parameter(Mandatory = $true)] [string] $TargetPath,
    [Parameter(Mandatory = $true)] [string] $ModId,
    [Parameter(Mandatory = $true)] [string] $ModDisplayName,
    [Parameter(Mandatory = $true)] [string] $ModDescriptionShort,
    [Parameter(Mandatory = $true)] [string] $ModDescriptionLong,
    [Parameter(Mandatory = $true)] [string] $ModAuthor,
    [Parameter(Mandatory = $false)] [string] $GithubUsername = '',
    [Parameter(Mandatory = $true)] [ValidateSet('Captain''s Chair','Apprentice','Master')] [string] $UserMode,
    [Parameter(Mandatory = $false)] [string] $ModdingRepoPath = '(not cloned)'
)

$ErrorActionPreference = 'Stop'

# --- Resolve and validate paths -------------------------------------------------

$LaunchpadPath = (Resolve-Path -LiteralPath $LaunchpadPath).Path
$templateRoot  = Join-Path $LaunchpadPath 'template'
if (-not (Test-Path -LiteralPath $templateRoot)) {
    throw "Launchpad has no template/ folder at: $templateRoot"
}

# Refuse to overwrite an existing mod project.
if (Test-Path -LiteralPath (Join-Path $TargetPath 'manifest.json')) {
    throw "Target already contains a manifest.json - refusing to overwrite: $TargetPath"
}

New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
$TargetPath = (Resolve-Path -LiteralPath $TargetPath).Path

# --- Load profile block ---------------------------------------------------------

$modeSlug = switch ($UserMode) {
    "Captain's Chair"     { 'captains-chair' }
    'Apprentice'          { 'apprentice' }
    'Master'              { 'master' }
}
$profileBlockPath = Join-Path $LaunchpadPath ".claude/skills/kickoff/profile-blocks/$modeSlug.md"
if (-not (Test-Path -LiteralPath $profileBlockPath)) {
    throw "Profile block not found: $profileBlockPath"
}
$profileBlock = [System.IO.File]::ReadAllText($profileBlockPath, [System.Text.Encoding]::UTF8).TrimEnd()

# --- Build substitution map -----------------------------------------------------

$guid = [guid]::NewGuid().ToString().ToUpper()
$year = (Get-Date).Year.ToString()

# Manifest needs JSON-escaped strings. Order matters: backslash first.
function ConvertTo-JsonString([string]$s) {
    $s = $s -replace '\\', '\\'
    $s = $s -replace '"',  '\"'
    $s = $s -replace "`r`n", '\n'
    $s = $s -replace "`n",   '\n'
    $s = $s -replace "`r",   '\n'
    $s = $s -replace "`t",   '\t'
    return $s
}

$subsPlain = [ordered]@{
    'MOD_ID'                  = $ModId
    'MOD_DISPLAY_NAME'        = $ModDisplayName
    'MOD_DESCRIPTION_SHORT'   = $ModDescriptionShort
    'MOD_DESCRIPTION_LONG'    = $ModDescriptionLong
    'MOD_AUTHOR'              = $ModAuthor
    'GITHUB_USERNAME'         = $GithubUsername
    'YEAR'                    = $year
    'USER_MODE'               = $UserMode
    'MODDING_REPO_PATH'       = $ModdingRepoPath
    'LAUNCHPAD_PATH'          = $LaunchpadPath
    'PROJECT_GUID'            = $guid
    'USER_PROFILE_BLOCK'      = $profileBlock
}

$subsJson = [ordered]@{}
foreach ($k in $subsPlain.Keys) { $subsJson[$k] = ConvertTo-JsonString ([string]$subsPlain[$k]) }

# --- Copy template into target --------------------------------------------------
# Exclude build/IDE noise. The launchpad shouldn't have these, but guard anyway.

$excludeDirs = @('bin','obj','.vs','.idea','.git','node_modules')

function Copy-FilteredTree([string]$From, [string]$To) {
    New-Item -ItemType Directory -Path $To -Force | Out-Null
    Get-ChildItem -LiteralPath $From -Force | ForEach-Object {
        if ($_.PSIsContainer -and ($excludeDirs -contains $_.Name)) { return }
        $dest = Join-Path $To $_.Name
        if ($_.PSIsContainer) {
            Copy-FilteredTree $_.FullName $dest
        } else {
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
        }
    }
}

Copy-FilteredTree $templateRoot $TargetPath

# --- Substitute file contents (UTF-8 in, UTF-8 no-BOM + CRLF out) ---------------

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Treat these as text (skip everything else - keeps binaries safe if any are added later).
$textExt = @('.cs','.csproj','.sln','.json','.md','.txt','.ps1','.gitignore','.gitattributes','.editorconfig','.yml','.yaml','.xml')

Get-ChildItem -Path $TargetPath -Recurse -File | ForEach-Object {
    $f = $_
    $ext = $f.Extension.ToLowerInvariant()
    $isText = ($textExt -contains $ext) -or ($f.Name -in @('.gitignore','.gitattributes','LICENSE'))
    if (-not $isText) { return }

    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    if ($null -eq $content) { return }

    # Pick which substitution map to use.
    $useJson = ($f.Name -eq 'manifest.json')
    $map = if ($useJson) { $subsJson } else { $subsPlain }

    $new = $content
    foreach ($k in $map.Keys) { $new = $new.Replace("{{$k}}", [string]$map[$k]) }

    # Normalize line endings to CRLF (Windows-only target).
    $new = $new -replace "`r`n", "`n"
    $new = $new -replace "`n",   "`r`n"

    [System.IO.File]::WriteAllText($f.FullName, $new, $utf8NoBom)
}

# --- Rename files with placeholders in their names ------------------------------

Get-ChildItem -Path $TargetPath -Recurse -File | Where-Object { $_.Name -match '\{\{' } | ForEach-Object {
    $newName = $_.Name
    foreach ($k in $subsPlain.Keys) { $newName = $newName.Replace("{{$k}}", [string]$subsPlain[$k]) }
    if ($newName -ne $_.Name) { Rename-Item -LiteralPath $_.FullName -NewName $newName }
}

# --- Generate .claude/local-paths.md (gitignored, machine-specific) -------------
# Built inline rather than shipped from the template, because template/.gitignore
# would otherwise prevent it from being tracked in the launchpad repo itself.

$localPathsContent = @"
# Local paths - machine-specific

This file lists paths on the current machine that are **specific to where you cloned things**. It is **gitignored** so it stays on this machine only - never push it, never share it.

If you're reading this on a freshly-cloned repo from someone else, these paths probably won't match where things live on your machine. Update them.

## Paths

- **Launchpad (COI Mod Template):** ``$LaunchpadPath``
  Re-run ``/kickoff`` there if you want to spawn another mod.

- **Official Captain of Industry modding examples repo:** ``$ModdingRepoPath``
  Used for the Research Protocol in ``CLAUDE.md`` (step 2). Real working code from the game devs.

- **Game install (``COI_ROOT``):** read from the user-scope environment variable.
  PowerShell: ``[Environment]::GetEnvironmentVariable('COI_ROOT','User')``

## How Claude uses this file

``CLAUDE.md`` instructs Claude to look here for machine-specific paths instead of having them hardcoded into the committed ``CLAUDE.md``. When Claude needs the modding examples repo for research and it's not where this file says, ask the user and update this file.
"@

# Normalize to CRLF for consistency with the rest of the spawned files.
$localPathsContent = $localPathsContent -replace "`r`n", "`n"
$localPathsContent = $localPathsContent -replace "`n",   "`r`n"

$localPathsDir = Join-Path $TargetPath '.claude'
New-Item -ItemType Directory -Path $localPathsDir -Force | Out-Null
[System.IO.File]::WriteAllText((Join-Path $localPathsDir 'local-paths.md'), $localPathsContent, $utf8NoBom)

# --- Sanity check: no leftover {{PLACEHOLDER}} tokens anywhere -----------------

$leftovers = Get-ChildItem -Path $TargetPath -Recurse -File |
    Select-String -Pattern '\{\{[A-Z_]+\}\}' -List
if ($leftovers) {
    $report = ($leftovers | ForEach-Object { "  $($_.Path): $($_.Line.Trim())" }) -join "`n"
    throw "Placeholder substitution incomplete - leftover tokens:`n$report"
}

Write-Output "Spawned: $TargetPath"
