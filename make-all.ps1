Write-Host "Zipping groups..."
. ".\zip-groups.ps1" | Out-Null

Write-Host "Zipping objects..."
. ".\zip-objects.ps1" | Out-Null

$homepath = Get-Location
$dist = "$($homepath)\dist"
$documents = [Environment]::GetFolderPath("MyDocuments")
$openRct2object = "$($documents)\OpenRct2\object\dkso"

Write-Host "Deleting old objects from OpenRCT2..."
Get-ChildItem -Path $openRct2object -Include *.* -Recurse | foreach { $_.Delete()}

Write-Host "Installing new objects in OpenRTC2..."
Get-ChildItem -Path $dist -File | Move-Item -Destination $openRct2object -Force
Write-Host "Done"
