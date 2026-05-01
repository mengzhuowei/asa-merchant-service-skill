param(
    [string]$SkillName = "asa-merchant-service",
    [string]$SourcePath = "",
    [string]$CodexHome = "",
    [switch]$ForceUpgrade
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    $SourcePath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
} else {
    $SourcePath = (Resolve-Path $SourcePath).Path
}

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $CodexHome = $env:CODEX_HOME
    } else {
        $CodexHome = Join-Path $HOME ".codex"
    }
}

$SkillRoot = Join-Path $CodexHome "skills"
$TargetPath = Join-Path $SkillRoot $SkillName
$ResolvedSkillRoot = [System.IO.Path]::GetFullPath($SkillRoot)
$ResolvedTargetPath = [System.IO.Path]::GetFullPath($TargetPath)

if (-not (Test-Path (Join-Path $SourcePath "SKILL.md"))) {
    throw "Invalid source path: SKILL.md not found in $SourcePath"
}

if (-not (Test-Path $SkillRoot)) {
    New-Item -ItemType Directory -Path $SkillRoot -Force | Out-Null
}

if (Test-Path $TargetPath) {
    if (-not $ForceUpgrade) {
        Write-Host "Skill already installed at: $TargetPath"
        exit 0
    }

    if (-not $ResolvedTargetPath.StartsWith($ResolvedSkillRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove path outside skill root: $ResolvedTargetPath"
    }

    Remove-Item -LiteralPath $TargetPath -Recurse -Force
}

New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null

Get-ChildItem -Path $SourcePath -Force | Where-Object {
    $_.Name -notin @(".git", ".gitignore")
} | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $TargetPath -Recurse -Force
}

if ($ForceUpgrade) {
    Write-Host "Upgraded skill '$SkillName' at: $TargetPath"
} else {
    Write-Host "Installed skill '$SkillName' to: $TargetPath"
}
