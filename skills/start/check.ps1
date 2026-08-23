# Report what a student has for water park's Start here. Windows PowerShell. Never changes anything.
# Prints the same JSON shape as check.sh.
$ErrorActionPreference = "SilentlyContinue"
$fountainUrl = if ($env:FOUNTAIN_URL) { $env:FOUNTAIN_URL } else { "http://localhost:4000" }
$flociUrl = if ($env:AWS_ENDPOINT_URL) { $env:AWS_ENDPOINT_URL } else { "http://localhost:4566" }

function Have($name) { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }
function Ver($cmd) { try { (& $cmd 2>$null | Select-Object -First 1) -join "" } catch { "" } }
function Reach($url) { try { $r = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing; $true } catch { if ($_.Exception.Response) { $true } else { $false } } }

$root = (git rev-parse --show-toplevel 2>$null)
$checkout = $false; $commit = ""
if ($root -and (Test-Path "$root/skills/start/SKILL.md") -and (Test-Path "$root/hugo.toml")) { $checkout = $true; $commit = (git -C $root rev-parse --short HEAD 2>$null) }

$tools = @{}
foreach ($t in "docker","fountain","floci","aws","jq","gh") {
  if (Have $t) {
    $v = switch ($t) { "docker" { Ver { docker --version } } "fountain" { Ver { fountain --version } } "floci" { Ver { floci --version } } "aws" { Ver { aws --version } } "jq" { Ver { jq --version } } "gh" { Ver { gh --version } } }
    $tools[$t] = @{ installed = $true; version = "$v" }
  } else { $tools[$t] = @{ installed = $false } }
}
$loggedIn = $false; if (Have "fountain") { fountain auth status *> $null; if ($LASTEXITCODE -eq 0) { $loggedIn = $true } }
$ghLoggedIn = $false; if (Have "gh") { gh auth status *> $null; if ($LASTEXITCODE -eq 0) { $ghLoggedIn = $true } }
$profile = if ($env:FOUNTAIN_PROFILE) { $env:FOUNTAIN_PROFILE } else { "default" }
$credUrl = ""
$credFile = Join-Path $HOME ".fountain/credentials"
if (Test-Path $credFile) {
  $inProfile = $false
  foreach ($line in Get-Content $credFile) {
    if ($line -eq "[$profile]") { $inProfile = $true; continue }
    if ($line -match '^\[') { $inProfile = $false }
    if ($inProfile -and $line -match '^base_url\s*=\s*"?([^"]+)"?') { $credUrl = $Matches[1] }
  }
}
$cliUrl = if ($env:FOUNTAIN_BASE_URL) { $env:FOUNTAIN_BASE_URL } else { $credUrl }

[ordered]@{
  waterpark = @{ checkout = $checkout; root = "$root"; commit = "$commit" }
  tools = $tools
  fountain = @{ url = $fountainUrl; reachable = (Reach "$fountainUrl/health"); logged_in = $loggedIn; cli_url = "$cliUrl"; profile = $profile }
  floci = @{ url = $flociUrl; reachable = (Reach "$flociUrl/") }
  github = @{ logged_in = $ghLoggedIn }
} | ConvertTo-Json -Depth 4
