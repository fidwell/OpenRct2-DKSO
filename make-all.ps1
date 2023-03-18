Write-Host "Zipping groups..."
. ".\zip-groups.ps1" | Out-Null

Write-Host "Zipping objects..."
. ".\zip-objects.ps1" | Out-Null

Write-Host "Installing objects in OpenRTC2..."

$homepath = Get-Location
$dist = "$($homepath)\dist"
$documents = [Environment]::GetFolderPath("MyDocuments")
$openRct2object = "$($documents)\OpenRct2\object"

Get-ChildItem -Path $dist -File | Move-Item -Destination $openRct2object -Force
Write-Host "Done"
