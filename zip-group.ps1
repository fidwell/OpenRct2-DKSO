$scgroups = "rct2.scenery_group.scgtrees", "rct2.scenery_group.scgshrub", "rct2.scenery_group.scggardn", "rct2.scenery_group.scgfence", "rct2.scenery_group.scgwalls", "rct2.scenery_group.scgpathx", "rct2.scenery_group.scgabstr", "rct2.scenery_group.scgclass", "rct2.scenery_group.scgegypt", "rct2.scenery_group.scghallo", "rct2.scenery_group.scgjungl", "rct2.scenery_group.scgjuras", "rct2.scenery_group.scgmart", "rct2.scenery_group.scgmedie", "rct2.scenery_group.scgmine", "rct2.scenery_group.scgorien", "rct2.scenery_group.scgsnow", "rct2.scenery_group.scgspace", "rct2.scenery_group.scgspook", "rct2.scenery_group.scgurban", "rct2.scenery_group.scgwond", "rct2.scenery_group.scgindus", "rct2.scenery_group.scggiant", "rct2.scenery_group.scgwater", "rct2.scenery_group.scgpirat", "rct2.scenery_group.scgsport", "rct2.scenery_group.scgwwest", "rct2.scenery_group.scgcandy", "rct2ww.scenery_group.scgafric", "rct2ww.scenery_group.scgartic", "rct2ww.scenery_group.scgasia", "rct2ww.scenery_group.scgaustr", "rct2ww.scenery_group.scgeurop", "rct2ww.scenery_group.scgnamrc", "rct2ww.scenery_group.scgsamer", "rct2tt.scenery_group.scgmediv", "rct2tt.scenery_group.scgfutur", "rct2tt.scenery_group.scgmytho", "rct2tt.scenery_group.scgjurra", "rct2tt.scenery_group.scg1920s", "rct2tt.scenery_group.scg1920w", "rct2tt.scenery_group.scg1960s", "rct2dlc.scenery_group.scgpanda", "rct2.scenery_group.scgsixfl"
$outnames = "fidwell.scenery_group.trees_dkso", "fidwell.scenery_group.shrubs_dkso", "fidwell.scenery_group.gardens_dkso", "fidwell.scenery_group.fences_dkso", "fidwell.scenery_group.walls_dkso", "fidwell.scenery_group.footpath_dkso", "fidwell.scenery_group.abstract_dkso", "fidwell.scenery_group.classical_dkso", "fidwell.scenery_group.egyptian_dkso", "fidwell.scenery_group.creepy_dkso", "fidwell.scenery_group.jungle_dkso", "fidwell.scenery_group.jurassic_dkso", "fidwell.scenery_group.martian_dkso", "fidwell.scenery_group.medieval_dkso", "fidwell.scenery_group.mine_dkso", "fidwell.scenery_group.pagoda_dkso", "fidwell.scenery_group.snow_dkso", "fidwell.scenery_group.space_dkso", "fidwell.scenery_group.spooky_dkso", "fidwell.scenery_group.urban_dkso", "fidwell.scenery_group.wonderland_dkso", "fidwell.scenery_group.mechanical_dkso", "fidwell.scenery_group.ggarden_dkso", "fidwell.scenery_group.water_dkso", "fidwell.scenery_group.pirates_dkso", "fidwell.scenery_group.sports_dkso", "fidwell.scenery_group.wildwest_dkso", "fidwell.scenery_group.gcandy_dkso", "fidwell.scenery_group.africa_dkso", "fidwell.scenery_group.antarctic_dkso", "fidwell.scenery_group.asia_dkso", "fidwell.scenery_group.australasia_dkso", "fidwell.scenery_group.europe_dkso", "fidwell.scenery_group.namerica_dkso", "fidwell.scenery_group.samerica_dkso", "fidwell.scenery_group.darkage_dkso", "fidwell.scenery_group.future_dkso", "fidwell.scenery_group.mythological_dkso", "fidwell.scenery_group.prehistoric_dkso", "fidwell.scenery_group.twenties_dkso", "fidwell.scenery_group.twentieswall_dkso", "fidwell.scenery_group.rocknroll_dkso'", "fidwell.scenery_group.panda_dkso", "fidwell.scenery_group.sixflags_dkso"

$homepath = Get-Location

$grouptotal = 0
$groupSuccess = 0

$outdir = "./dist"
New-Item $outdir -ItemType Directory

for ($i = 0; $i -lt $scgroups.Length; ++$i) {
    # go home
    Set-Location $homepath

    $scgroup = $scgroups[$i]
    $outname = $outnames[$i]
    $outfile = "$homepath/$outdir/$outname.parkobj"

    # remove old zip file
    if (Test-Path $outfile) { Remove-Item $outfile -ErrorAction Stop }

    # go inside subdirectory
    Set-Location "groups/$scgroup"

    # get file list
    $Files = @(Get-ChildItem "./" -Recurse -File | Where-Object {$_.name -NotMatch "$scgroup.png"})
    $FullFilenames = $files | ForEach-Object -Process {Write-Output -InputObject $_.FullName}

    $groupTotal += 1

    if ($Files.Count -ne 3)
    {
        Write-Output "Not the right files for $scgroup"
        continue
    }

    Write-Output "Zipping $scgroup..."

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

    $groupSuccess += 1
}

# go home
Set-Location $homepath

Write-Output "Created $groupSuccess out of $groupTotal groups."
