# HobbyMatch - script de lanzamiento
# Usa D:\Temp para evitar errores cuando C: esta casi lleno.

Set-Location $PSScriptRoot

$tempDir = "D:\Temp"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

$env:TEMP = $tempDir
$env:TMP = $tempDir

$cFree = (Get-Volume -DriveLetter C -ErrorAction SilentlyContinue).SizeRemaining
if ($cFree -and $cFree -lt 2GB) {
    Write-Host "AVISO: C: tiene poco espacio libre. Si falla, libera al menos 5 GB." -ForegroundColor Yellow
}

Write-Host "TEMP -> $tempDir" -ForegroundColor Cyan
flutter pub get | Out-Null

$device = $args[0]
if (-not $device) {
    $device = "edge"
}

Write-Host "Lanzando en: $device" -ForegroundColor Cyan
flutter run -d $device
