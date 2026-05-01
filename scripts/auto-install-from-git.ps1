param(
    [string]$RepoUrl = "https://github.com/mengzhuowei/asa-merchant-service-skill.git",
    [string]$Ref = "main",
    [string]$SkillName = "asa-merchant-service",
    [string]$CodexHome = "",
    [switch]$ForceUpgrade = $true
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $CodexHome = $env:CODEX_HOME
    } else {
        $CodexHome = Join-Path $HOME ".codex"
    }
}

$TargetPath = Join-Path (Join-Path $CodexHome "skills") $SkillName
if (Test-Path $TargetPath) {
    if (-not $ForceUpgrade) {
        Write-Host "Skill already installed at: $TargetPath"
        exit 0
    }

    Write-Host "Force upgrade enabled, will refresh: $TargetPath"
}

$TempPath = Join-Path $env:TEMP ("skill-install-" + [guid]::NewGuid().ToString())

try {
    git clone --depth 1 --branch $Ref $RepoUrl $TempPath | Out-Null
    & (Join-Path $TempPath "scripts/install.ps1") -SkillName $SkillName -SourcePath $TempPath -CodexHome $CodexHome -ForceUpgrade:$ForceUpgrade
} finally {
    if (Test-Path $TempPath) {
        Remove-Item -LiteralPath $TempPath -Recurse -Force
    }
}
