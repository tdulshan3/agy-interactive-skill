<#
.SYNOPSIS
  Install the agy-interactive skill and always-on narration rule for Google Antigravity (agy) and dsh.

.DESCRIPTION
  Installs or links the agy-interactive skill and inserts/updates the managed narration rule block
  in ~/.gemini/config/rules/AGENTS.md and ~/.dsh/AGENTS.md.

.PARAMETER Action
  Install (default), Status, or Uninstall.
#>

[CmdletBinding()]
param(
  [ValidateSet("install", "status", "uninstall")]
  [string]$Action = "install"
)

$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot
$SkillName = "agy-interactive"
$SkillSrc = Join-Path $RepoDir $SkillName

$Harnesses = @(
  @{
    Name = "antigravity"
    Detect = Join-Path $HOME ".gemini"
    Skills = Join-Path $HOME ".gemini\config\skills"
    Rules = Join-Path $HOME ".gemini\config\rules\AGENTS.md"
  },
  @{
    Name = "dsh"
    Detect = Join-Path $HOME ".dsh"
    Skills = Join-Path $HOME ".agents\skills"
    Rules = Join-Path $HOME ".dsh\AGENTS.md"
  }
)

$BeginTag = "<!-- agy-interactive:begin -->"
$EndTag = "<!-- agy-interactive:end -->"

$Block = @"
$BeginTag
- Before each tool call (or batch of parallel calls), briefly say what you're doing and why, thinking out loud like a teammate.
$EndTag
"@

function Update-RulesFile {
  param(
    [string]$RulesFile,
    [string]$Mode
  )

  if ($Mode -eq "remove" -and -not (Test-Path $RulesFile)) {
    return
  }

  $RulesDir = Split-Path $RulesFile -Parent
  if (-not (Test-Path $RulesDir)) {
    New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null
  }

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $text = if (Test-Path $RulesFile) { [System.IO.File]::ReadAllText($RulesFile, $utf8NoBom) } else { "" }

  $managedPattern = [regex]::Escape($BeginTag) + "[\s\S]*?" + [regex]::Escape($EndTag)
  $legacyPattern = "(?m)^## (?:\d+\.\s*)?Interactive Progress & (?:Step-by-Step|Natural) Narration \([^\n]*\)\r?\n+(?:- .*\r?\n)+"

  if ($Mode -eq "remove") {
    $newText = [regex]::Replace($text, $managedPattern, "")
    $newText = [regex]::Replace($newText, "\n{3,}", "`n`n").Trim()
    if ($newText) { $newText += "`n" }
  } elseif ([regex]::IsMatch($text, $managedPattern)) {
    $newText = [regex]::Replace($text, $managedPattern, $Block)
  } elseif ([regex]::IsMatch($text, $legacyPattern)) {
    $newText = [regex]::Replace($text, $legacyPattern, $Block + "`n`n")
    $newText = [regex]::Replace($newText, "\n{3,}", "`n`n").Trim() + "`n"
  } elseif ($text -match "<!-- agent-memory:begin -->") {
    $newText = $text.Replace("<!-- agent-memory:begin -->", $Block + "`n`n<!-- agent-memory:begin -->")
  } else {
    $prefix = if ($text.Trim()) { $text.TrimEnd() + "`n`n" } else { "# Global Agent Rules`n`n" }
    $newText = $prefix + $Block + "`n"
  }

  if ($Mode -eq "remove" -and [string]::IsNullOrWhiteSpace($newText) -and (Test-Path $RulesFile)) {
    Remove-Item $RulesFile -Force
    Write-Host "  [REMOVED] $RulesFile"
  } elseif ($newText -ne $text) {
    [System.IO.File]::WriteAllText($RulesFile, $newText, $utf8NoBom)
    Write-Host "  [$($(if ($Mode -eq 'remove') {'REMOVED'} else {'RULES'}))] $RulesFile"
  } else {
    Write-Host "  [KEEP]  $RulesFile"
  }
}

function Link-SkillDirectory {
  param(
    [string]$Source,
    [string]$Destination
  )

  $DestParent = Split-Path $Destination -Parent
  if (-not (Test-Path $DestParent)) {
    New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
  }

  if (Test-Path $Destination) {
    Remove-Item -Path $Destination -Recurse -Force
  }

  try {
    # Attempt directory junction or symbolic link first
    New-Item -ItemType Junction -Path $Destination -Target $Source -ErrorAction Stop | Out-Null
    Write-Host "  [SKILL] $Destination (junction)"
  } catch {
    try {
      New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -ErrorAction Stop | Out-Null
      Write-Host "  [SKILL] $Destination (symlink)"
    } catch {
      Copy-Item -Path $Source -Destination $Destination -Recurse -Force
      Write-Host "  [SKILL] $Destination (copied)"
    }
  }
}

if ($Action -eq "status") {
  foreach ($harness in $Harnesses) {
    if (-not (Test-Path $harness.Detect)) {
      Write-Host "=== $($harness.Name): not installed on this machine"
      continue
    }
    Write-Host "=== $($harness.Name)"
    $skillPath = Join-Path $harness.Skills $SkillName
    if (Test-Path $skillPath) {
      $item = Get-Item $skillPath
      if ($item.LinkType) {
        Write-Host "  [SKILL]    $skillPath -> $($item.Target)"
      } else {
        Write-Host "  [SKILL]    $skillPath (installed directory)"
      }
    } else {
      Write-Host "  [MISSING]  $skillPath"
    }

    if (Test-Path $harness.Rules) {
      $content = Get-Content $harness.Rules -Raw
      if ($content -match "agy-interactive:begin") {
        Write-Host "  [AUTO]     $($harness.Rules)"
      } else {
        Write-Host "  [NO AUTO]  $($harness.Rules)"
      }
    } else {
      Write-Host "  [NO AUTO]  $($harness.Rules)"
    }
  }
  exit 0
}

if ($Action -eq "uninstall") {
  foreach ($harness in $Harnesses) {
    $skillPath = Join-Path $harness.Skills $SkillName
    if (Test-Path $skillPath) {
      Remove-Item -Path $skillPath -Recurse -Force
      Write-Host "  [REMOVED] $skillPath"
    }
    Update-RulesFile -RulesFile $harness.Rules -Mode "remove"
  }
  exit 0
}

# Default: install
foreach ($harness in $Harnesses) {
  if (-not (Test-Path $harness.Detect)) {
    Write-Host "=== $($harness.Name): not installed on this machine, skipped"
    continue
  }
  Write-Host "=== $($harness.Name)"
  $skillPath = Join-Path $harness.Skills $SkillName
  Link-SkillDirectory -Source $SkillSrc -Destination $skillPath
  Update-RulesFile -RulesFile $harness.Rules -Mode "write"
}
