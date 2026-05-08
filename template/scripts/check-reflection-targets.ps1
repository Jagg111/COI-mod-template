# check-reflection-targets.ps1
# Verifies that all reflection targets used by this mod still exist in the game DLLs.
# Run after a game update to quickly identify what broke.
#
# Usage: powershell -ExecutionPolicy Bypass -File scripts\check-reflection-targets.ps1
#
# This script scans every *.cs file in the project for ReflectionProbe calls,
# then checks each target against the actual game DLLs. The C# source is the
# single source of truth -- no separate list to maintain.
#
# If your mod doesn't use reflection (or doesn't use the ReflectionProbe helper
# pattern yet), this script will simply find nothing and report 0 targets.

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

if (-not $env:COI_ROOT) {
    Write-Host "ERROR: COI_ROOT environment variable not set." -ForegroundColor Red
    exit 1
}

$basePath = Join-Path $env:COI_ROOT "Captain of Industry_Data\Managed"

if (-not (Test-Path $basePath)) {
    Write-Host "ERROR: Game DLL path not found: $basePath" -ForegroundColor Red
    Write-Host "Make sure COI_ROOT environment variable is set correctly." -ForegroundColor Red
    exit 1
}

# Load game DLLs
$dllNames = @("Mafi.dll", "Mafi.Core.dll", "Mafi.Base.dll", "Mafi.Unity.dll")
$loadedAssemblies = @{}

foreach ($dll in $dllNames) {
    $dllPath = Join-Path $basePath $dll
    if (Test-Path $dllPath) {
        try {
            $asm = [System.Reflection.Assembly]::LoadFrom($dllPath)
            $loadedAssemblies[$dll] = $asm
        } catch {
            Write-Host "WARNING: Could not load $dll" -ForegroundColor Yellow
        }
    }
}

# Find all .cs files in the repo (excluding bin/obj)
$sourceFiles = Get-ChildItem -Path $repoRoot -Filter *.cs -Recurse |
    Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }

if ($sourceFiles.Count -eq 0) {
    Write-Host "No .cs files found in repo." -ForegroundColor Yellow
    exit 0
}

# Combine all source content for scanning
$source = ($sourceFiles | ForEach-Object { Get-Content $_.FullName -Raw }) -join "`n"

$results = @()

# Match Field/Method calls with typeof(...)
$fieldMethodPattern = 'ReflectionProbe\.(Field|Method)\(\s*typeof\((\w+)\)\s*,\s*"([^"]+)"\s*,\s*(BindingFlags\.[^,]+(?:\s*\|\s*BindingFlags\.\w+)*)\s*,\s*"([^"]+)"'
$matches = [regex]::Matches($source, $fieldMethodPattern)
foreach ($m in $matches) {
    $results += @{
        Kind = $m.Groups[1].Value.ToLower()
        TypeName = $m.Groups[2].Value
        MemberName = $m.Groups[3].Value
        Flags = $m.Groups[4].Value
        Feature = $m.Groups[5].Value
    }
}

# Dynamic field/property probes (can't be checked offline)
$dynamicFieldPattern = 'ReflectionProbe\.Field\(\s*(?:_\w+\.(?:GetType\(\)|FieldType)|_\w+\.GetType\(\)\.BaseType)\s*,\s*"([^"]+)"\s*,\s*(BindingFlags\.[^,]+(?:\s*\|\s*BindingFlags\.\w+)*)\s*,\s*"([^"]+)"'
$dynamicMatches = [regex]::Matches($source, $dynamicFieldPattern)

$dynamicPropPattern = 'ReflectionProbe\.Property\(\s*(?:\w+\.GetType\(\))\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"'
$dynamicPropMatches = [regex]::Matches($source, $dynamicPropPattern)

# Match Property calls with typeof(...)
$propertyPattern = 'ReflectionProbe\.Property\(\s*typeof\((\w+)\)\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"'
$propMatches = [regex]::Matches($source, $propertyPattern)
foreach ($m in $propMatches) {
    $results += @{
        Kind = "property"
        TypeName = $m.Groups[1].Value
        MemberName = $m.Groups[2].Value
        Flags = "Public,Instance"
        Feature = $m.Groups[3].Value
    }
}

# Type probes
$typeProbePattern = 'ReflectionProbe\.RecordTypeProbe\(\s*"([^"]+)"'
$typeMatches = [regex]::Matches($source, $typeProbePattern)

$totalTargets = $results.Count + $typeMatches.Count + $dynamicMatches.Count + $dynamicPropMatches.Count

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Reflection Target Check" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if ($totalTargets -eq 0) {
    Write-Host "  No ReflectionProbe targets found in source." -ForegroundColor Yellow
    Write-Host "  Either this mod doesn't use reflection yet, or it doesn't" -ForegroundColor Yellow
    Write-Host "  use the ReflectionProbe helper pattern. Both are fine." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

$passed = 0
$failed = 0
$skipped = 0

# Check statically-typed targets
foreach ($target in $results) {
    $typeName = $target.TypeName
    $memberName = $target.MemberName
    $kind = $target.Kind
    $feature = $target.Feature

    $foundType = $null
    foreach ($asm in $loadedAssemblies.Values) {
        $types = @()
        try { $types = $asm.GetTypes() } catch [System.Reflection.ReflectionTypeLoadException] {
            $types = $_.Exception.Types | Where-Object { $_ -ne $null }
        }
        $match = $types | Where-Object { $_.Name -eq $typeName } | Select-Object -First 1
        if ($match) { $foundType = $match; break }
    }

    if (-not $foundType) {
        Write-Host "  FAIL  " -NoNewline -ForegroundColor Red
        Write-Host "$kind '$memberName' -- type '$typeName' not found -- $feature"
        $failed++
        continue
    }

    $bindingFlags = [System.Reflection.BindingFlags]::Default
    if ($target.Flags -match "NonPublic") { $bindingFlags = $bindingFlags -bor [System.Reflection.BindingFlags]::NonPublic }
    if ($target.Flags -match "Public") { $bindingFlags = $bindingFlags -bor [System.Reflection.BindingFlags]::Public }
    if ($target.Flags -match "Instance") { $bindingFlags = $bindingFlags -bor [System.Reflection.BindingFlags]::Instance }
    if ($target.Flags -match "Static") { $bindingFlags = $bindingFlags -bor [System.Reflection.BindingFlags]::Static }

    $found = $false
    switch ($kind) {
        "field" { $found = $null -ne $foundType.GetField($memberName, $bindingFlags) }
        "property" { $found = $null -ne $foundType.GetProperty($memberName) }
        "method" { $found = $null -ne $foundType.GetMethod($memberName, $bindingFlags) }
    }

    if ($found) {
        Write-Host "  PASS  " -NoNewline -ForegroundColor Green
        Write-Host "$kind '$memberName' on $($foundType.FullName) -- $feature"
        $passed++
    } else {
        Write-Host "  FAIL  " -NoNewline -ForegroundColor Red
        Write-Host "$kind '$memberName' on $($foundType.FullName) -- $feature"
        $failed++
    }
}

# Type probes
foreach ($m in $typeMatches) {
    $fullName = $m.Groups[1].Value
    $foundType = $null
    foreach ($asm in $loadedAssemblies.Values) {
        try { $foundType = $asm.GetType($fullName) } catch {}
        if ($foundType) { break }

        $types = @()
        try { $types = $asm.GetTypes() } catch [System.Reflection.ReflectionTypeLoadException] {
            $types = $_.Exception.Types | Where-Object { $_ -ne $null }
        }
        $match = $types | Where-Object { $_.FullName -eq $fullName } | Select-Object -First 1
        if ($match) { $foundType = $match; break }
    }

    if ($foundType) {
        Write-Host "  PASS  " -NoNewline -ForegroundColor Green
        Write-Host "type '$fullName'"
        $passed++
    } else {
        $hasSubtypes = $false
        foreach ($asm in $loadedAssemblies.Values) {
            $types = @()
            try { $types = $asm.GetTypes() } catch [System.Reflection.ReflectionTypeLoadException] {
                $types = $_.Exception.Types | Where-Object { $_ -ne $null }
            }
            $sub = $types | Where-Object { $_.FullName -like "$fullName+*" } | Select-Object -First 1
            if ($sub) { $hasSubtypes = $true; break }
        }

        if ($hasSubtypes) {
            Write-Host "  PASS* " -NoNewline -ForegroundColor Green
            Write-Host "type '$fullName' (subtypes found; parent type unloadable outside game runtime)"
            $passed++
        } else {
            Write-Host "  FAIL  " -NoNewline -ForegroundColor Red
            Write-Host "type '$fullName'"
            $failed++
        }
    }
}

# Dynamic-type probes
$dynamicTotal = $dynamicMatches.Count + $dynamicPropMatches.Count
if ($dynamicTotal -gt 0) {
    Write-Host ""
    Write-Host "  Dynamic-type probes (require game runtime to verify):" -ForegroundColor Yellow
    foreach ($m in $dynamicMatches) {
        Write-Host "  SKIP  " -NoNewline -ForegroundColor Yellow
        Write-Host "field '$($m.Groups[1].Value)' -- $($m.Groups[3].Value)"
        $skipped++
    }
    foreach ($m in $dynamicPropMatches) {
        Write-Host "  SKIP  " -NoNewline -ForegroundColor Yellow
        Write-Host "property '$($m.Groups[1].Value)' -- $($m.Groups[2].Value)"
        $skipped++
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Results: $passed PASS, $failed FAIL, $skipped SKIP" -ForegroundColor Cyan
if ($failed -gt 0) {
    Write-Host "  Action: Run scripts\inspect_dll.ps1 on failed types to see what changed" -ForegroundColor Yellow
}
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
