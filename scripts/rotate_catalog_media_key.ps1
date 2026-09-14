param(
  [string]$PythonExecutable = 'python',
  [string]$WranglerVersion = '4.131.0'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$keyBytes = New-Object byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Fill($keyBytes)
$keyBase64 = [Convert]::ToBase64String($keyBytes)

Push-Location $projectRoot
try {
  $env:CATALOG_MEDIA_AES_KEY = $keyBase64
  & $PythonExecutable 'scripts\encrypt_catalog_media.py'
  if ($LASTEXITCODE -ne 0) { throw 'Catalog media encryption failed.' }

  $keyBase64 | & npx.cmd --yes "wrangler@$WranglerVersion" pages secret put CATALOG_MEDIA_AES_KEY --project-name sidi-achour-crm
  if ($LASTEXITCODE -ne 0) { throw 'Pages Secret update failed.' }
} finally {
  Remove-Item Env:CATALOG_MEDIA_AES_KEY -ErrorAction SilentlyContinue
  [Array]::Clear($keyBytes, 0, $keyBytes.Length)
  $keyBase64 = $null
  Pop-Location
}
