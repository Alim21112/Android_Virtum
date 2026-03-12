param(
  [string]$DeviceId
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendPath = Join-Path $root "backend"
$mobilePath = Join-Path $root "mobile"

if (-not (Test-Path (Join-Path $backendPath "node_modules"))) {
  Push-Location $backendPath
  npm install
  Pop-Location
}

Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoProfile",
  "-ExecutionPolicy",
  "Bypass",
  "-Command",
  "cd `"$backendPath`"; npm start"
)

if (-not (Test-Path (Join-Path $mobilePath ".dart_tool\package_config.json"))) {
  Push-Location $mobilePath
  flutter pub get
  Pop-Location
}

Push-Location $mobilePath
if ($DeviceId) {
  flutter run -d $DeviceId
} else {
  flutter run
}
Pop-Location
