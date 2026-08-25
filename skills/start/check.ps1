# Report what a student has for water park's Start here. Windows PowerShell. Never changes anything.
# Prints the same JSON shape as check.sh. `check.ps1 doctor` prints a human
# report instead, with the install or fix line for whatever is missing.
$ErrorActionPreference = "SilentlyContinue"

function Have($name) { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }
function Ver($cmd) { try { (& $cmd 2>$null | Select-Object -First 1) -join "" } catch { "" } }
function Reach($url) { try { $r = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing; $true } catch { if ($_.Exception.Response) { $true } else { $false } } }

$root = (git rev-parse --show-toplevel 2>$null)
$checkout = $false; $commit = ""
if ($root -and (Test-Path "$root/skills/start/SKILL.md") -and (Test-Path "$root/hugo.toml")) { $checkout = $true; $commit = (git -C $root rev-parse --short HEAD 2>$null) }

# with the compose stack on non-default ports, follow compose/.env unless FOUNTAIN_URL / AWS_ENDPOINT_URL say otherwise
$composePort = $null; $composeFlociPort = $null
$composeEnvFile = if ($root) { Join-Path $root "compose/.env" } else { $null }
if ($composeEnvFile -and (Test-Path $composeEnvFile)) {
  foreach ($line in Get-Content $composeEnvFile) {
    if ($line -match '^PORT=(.*)') { $composePort = $Matches[1] }
    if ($line -match '^FLOCI_PORT=(.*)') { $composeFlociPort = $Matches[1] }
  }
}
$fountainUrl = if ($env:FOUNTAIN_URL) { $env:FOUNTAIN_URL } else { "http://localhost:$(if ($composePort) { $composePort } else { 4000 })" }
$flociUrl = if ($env:AWS_ENDPOINT_URL) { $env:AWS_ENDPOINT_URL } else { "http://localhost:$(if ($composeFlociPort) { $composeFlociPort } else { 4566 })" }

$tools = @{}
foreach ($t in "docker","fountain","floci","aws","jq","gh","just") {
  if (Have $t) {
    $v = switch ($t) { "docker" { Ver { docker --version } } "fountain" { Ver { fountain --version } } "floci" { Ver { floci --version } } "aws" { Ver { aws --version } } "jq" { Ver { jq --version } } "gh" { Ver { gh --version } } "just" { Ver { just --version } } }
    $tools[$t] = @{ installed = $true; version = "$v" }
  } else { $tools[$t] = @{ installed = $false } }
}
$loggedIn = $false
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
$credKey = ""
if (Test-Path $credFile) {
  $inProfile = $false
  foreach ($line in Get-Content $credFile) {
    if ($line -eq "[$profile]") { $inProfile = $true; continue }
    if ($line -match '^\[') { $inProfile = $false }
    if ($inProfile -and $line -match '^api_key\s*=\s*"?([^"]+)"?') { $credKey = $Matches[1] }
  }
}
$inferenceSet = $false; $onboarded = $false; $runnerOnline = $false; $meEmail = ""
if ($credKey -and $cliUrl) {
  try {
    $m = Invoke-RestMethod -Uri "$cliUrl/api/auth/me" -Headers @{Authorization = "Bearer $credKey"} -TimeoutSec 5
    $loggedIn = $true; $meEmail = $m.email
    if ($m.onboarding_completed) { $onboarded = $true }
    try { $c = Invoke-RestMethod -Uri "$cliUrl/api/account/inference-credentials" -Headers @{Authorization = "Bearer $credKey"} -TimeoutSec 5; if (($c | ConvertTo-Json) -match "true") { $inferenceSet = $true } } catch {}
    try { $r = Invoke-RestMethod -Uri "$cliUrl/api/runners" -Headers @{Authorization = "Bearer $credKey"} -TimeoutSec 5; if (($r | ConvertTo-Json) -match '"online":\s*true') { $runnerOnline = $true } } catch {}
  } catch {}
}

$pkgs = @(); foreach ($m in "winget","scoop","choco") { if (Have $m) { $pkgs += $m } }

if ($args.Count -gt 0 -and $args[0] -eq "doctor") {
  $checkMark = [char]0x2713
  $crossMark = [char]0x2717
  function Ok($name) { Write-Host ("  {0} {1}" -f $checkMark, $name) }
  function Bad($name, $fix) { Write-Host ("  {0} {1}" -f $crossMark, $name); Write-Host ("      fix: {0}" -f $fix) }

  $dockerFix = "winget install Docker.DockerDesktop   (WSL 2 backend)"
  $toolsFix = "winget install Amazon.AWSCLI jqlang.jq GitHub.cli   (or scoop install aws jq gh)"
  $justFix = "winget install Casey.Just   (or scoop install just)"
  $pkgLabel = "none"
  if ($pkgs.Count -gt 0) { $pkgLabel = $pkgs -join " " }

  Write-Host "water park doctor (Windows, package managers: $pkgLabel)"

  if ($checkout) { Ok "water park checkout ($root @ $commit)" }
  else { Bad "water park checkout" "git clone https://github.com/INTENTIUS/waterpark && cd waterpark" }

  if (Have "just") { Ok "just ($(Ver { just --version }))" }
  else { Bad "just" $justFix }

  if (Have "docker") { Ok "docker ($(Ver { docker --version }))" }
  else { Bad "docker" $dockerFix }

  if (Reach "$fountainUrl/health") { Ok "Fountain answering at $fountainUrl" }
  else { Bad "Fountain at $fountainUrl" "just up   (or set FOUNTAIN_URL to the class instance)" }

  if ($loggedIn) { Ok "logged in as $meEmail (profile $profile)" }
  else { Bad "logged in" "just register you@example.com   (prompts for a password)" }

  if ($inferenceSet) { Ok "inference key set" }
  else { Bad "inference key" "sign in at $(if ($cliUrl) { $cliUrl } else { $fountainUrl }) and finish onboarding, or the step-7 curl from the start skill" }

  if ($runnerOnline) { Ok "a runner is online" }
  else { Bad "runner" "just runner   (only needed when the stack's runner is the provider)" }

  if (Reach "$flociUrl/") { Ok "Floci answering at $flociUrl" }
  else { Bad "Floci at $flociUrl" "just up   (self-paced only; live students skip this)" }

  foreach ($t in "aws","jq","gh") {
    if (Have $t) { Ok $t } else { Bad $t $toolsFix }
  }

  exit 0
}

[ordered]@{
  waterpark = @{ checkout = $checkout; root = "$root"; commit = "$commit" }
  os = "Windows"
  package_managers = $pkgs
  tools = $tools
  fountain = @{ url = $fountainUrl; reachable = (Reach "$fountainUrl/health"); logged_in = $loggedIn; cli_url = "$cliUrl"; profile = $profile; inference_set = $inferenceSet; onboarded = $onboarded; runner_online = $runnerOnline; email = $meEmail }
  floci = @{ url = $flociUrl; reachable = (Reach "$flociUrl/") }
  github = @{ logged_in = $ghLoggedIn }
} | ConvertTo-Json -Depth 4
