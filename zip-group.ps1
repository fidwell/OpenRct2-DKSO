Write-Output "Zipping $scgroup..."

$scgroup = "rct2.scenery_group.scgabstr"
$outname = "fidwell.scenery_group.abstract_dkso"
$outdir = "./dist"
$homepath = Get-Location
$outfile = "$homepath/$outdir/$outname.parkobj"

# remove old zip file
if (Test-Path $outfile) { Remove-Item $outfile -ErrorAction Stop }

# go inside subdirectory
Set-Location $scgroup

# get file list
$Files = @(Get-ChildItem "./" -Recurse -File | Where-Object {$_.name -NotMatch "$scgroup.png"})
$FullFilenames = $files | ForEach-Object -Process {Write-Output -InputObject $_.FullName}

#create zip file
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open(($outfile), [System.IO.Compression.ZipArchiveMode]::Create)

# write entries with relative paths as names
foreach ($fname in $FullFilenames) {
    $rname = $(Resolve-Path -Path $fname -Relative) -replace '\.\\',''
    $zentry = $zip.CreateEntry($rname)
    $zentryWriter = New-Object -TypeName System.IO.BinaryWriter $zentry.Open()
    $zentryWriter.Write([System.IO.File]::ReadAllBytes($fname))
    $zentryWriter.Flush()
    $zentryWriter.Close()
}

# release zip file
$zip.Dispose()

# go home
Set-Location $homepath
