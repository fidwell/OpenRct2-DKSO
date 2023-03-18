$homepath = Get-Location

$objectTotal = 0
$objectSuccess = 0

$outdir = "$($homepath)/dist"
New-Item -Path $outdir -ItemType Directory -Force | Out-Null

Set-Location ./objects

$groupPaths = Get-ChildItem -Directory
foreach ($groupPath in $groupPaths) {
    Set-Location $groupPath

    $objectPaths = Get-ChildItem -Directory
    foreach ($objectPath in $objectPaths) {
        Set-Location $objectPath
        $objectTotal++

        if (Test-Path "images.json") {
            # Ignore paths with images.json in them, as they are probably not done
            Set-Location ..
            continue
        }

        $objectName = Split-Path -Path (Get-Location) -Leaf
        $outfile = "$($outdir)/$($objectName).parkobj"
        
        # Remove old zip file, if it exists
        if (Test-Path $outfile) {
            Remove-Item $outfile -ErrorAction Stop
        }
        
        Write-Output "Zipping $objectName..."
        
        # Get file list
        $Files = @(Get-ChildItem "./" -Recurse -File)
        $FullFilenames = $files | ForEach-Object -Process {Write-Output -InputObject $_.FullName}

        # Create zip file
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::Open(($outfile), [System.IO.Compression.ZipArchiveMode]::Create)

        # Write entries with relative paths as names
        foreach ($fname in $FullFilenames) {
            $rname = $(Resolve-Path -Path $fname -Relative) -replace '\.\\',''
            $zentry = $zip.CreateEntry($rname)
            $zentryWriter = New-Object -TypeName System.IO.BinaryWriter $zentry.Open()
            $zentryWriter.Write([System.IO.File]::ReadAllBytes($fname))
            $zentryWriter.Flush()
            $zentryWriter.Close()
        }

        # Release zip file
        $zip.Dispose()

        $objectSuccess += 1

        Set-Location ..
    }

    Set-Location ..
}

# go home
Set-Location $homepath

Write-Output "Created $objectSuccess out of $objectTotal objects."
