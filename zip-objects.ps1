Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.CompressionLevel]$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

$verbose = $args.length -eq 1 -and $args[0] -eq '-v'

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

        # Get object identifier from the file itself
        $objectName = (Select-String -Path .\object.json '"id": "([\w\.]*)"' -AllMatches).Matches.Groups[1].Value
        $outfile = "$($outdir)/$($objectName).parkobj"
        
        # Remove old zip file, if it exists
        if (Test-Path $outfile) {
            Remove-Item $outfile -ErrorAction Stop
        }
        
        if ($verbose) {
            Write-Output "Zipping $objectName..."
        }
        
        # Get file list
        $Files = @(Get-ChildItem "./" -Recurse -File)
        $FullFilenames = $files | ForEach-Object -Process {Write-Output -InputObject $_.FullName}

        # Create zip file
        try {
            $zip = [System.IO.Compression.ZipFile]::Open($outfile, [System.IO.Compression.ZipArchiveMode]::Create)
            # Write entries with relative paths as names
            foreach ($fname in $FullFilenames) {
                $entryName = Split-Path $fname -Leaf
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $fname, $entryName, $compressionLevel)
            }
        } finally {
        }

        # Release zip file
        $zip.Dispose()

        $objectSuccess += 1

        Set-Location ..
    }

    Set-Location ..
}

# Go home
Set-Location $homepath

Write-Output "Created $objectSuccess out of $objectTotal objects."
