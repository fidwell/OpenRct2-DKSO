$rctIdentifier = $args[0]
$openRct2Identifier = $args[1]
$customIdentifier = $args[2]

$documents = [Environment]::GetFolderPath("MyDocuments")
$openRct2bin = "$($documents)\OpenRct2\bin"
$openRct2com = "$($openRct2bin)\openrct2.com"

$namespace = "fidwell"

function ExtractSprites(
    [string]$objectPath,
    [string]$imagePath,
    [string]$customIdentifier,
    [string]$rctIdentifier)
{
    Write-Host "Creating directories..."
    New-Item -Path "$($objectPath)" -ItemType Directory -Force | Out-Null
    New-Item -Path "$($imagePath)" -ItemType Directory -Force | Out-Null

    $command = ""
    if ($customIdentifier.Length -eq 0)
    {
        Write-Host "Extracting vanilla object..."
        $command = "$($openRct2com) sprite exportalldat $($rctIdentifier) $($imagePath) > $($objectPath)/images.json"
    }
    else
    {
        Write-Host "Extracting custom object..."
        $command = "$($openRct2com) sprite exportalldat $($customIdentifier) $($imagePath) > $($objectPath)/images.json"
    }

    Invoke-Expression -Command $command
}

function CopyData(
    [string]$openRct2bin,
    [string]$originalGame,
    [string]$objectType,
    [string]$openRct2Identifier,
    [string]$objectJson)
{
    Write-Host "Copying json..."
    $source = "$($openRct2bin)\data\object\$($originalGame)\$($objectType)\$($openRct2Identifier).json"
    Copy-Item $source -Destination $objectJson
}

function EditJson(
    [string]$openRct2Identifier,
    [string]$objectJson,
    [string]$newIdentifier)
{
    Write-Host "Editing json..."

    # Replace id
	$regex = [regex]::Escape("""id"": ""$($openRct2Identifier)"",")
	(Get-Content $objectJson) -replace $regex, """id"": ""$($newIdentifier)""," | Set-Content $objectJson

    # Change or remove original id
    $regex = "\""originalId\"": \"".*"
	(Get-Content $objectJson) -replace $regex, """originalId"": """"," | Set-Content $objectJson

    # Change source game
    $regex = "\""sourceGame\"": \[.*"
	(Get-Content $objectJson) -replace $regex, """sourceGame"": [""custom""]," | Set-Content $objectJson
    # to do

    # Add recolorable flags
    # to do

    # Add images
    # to do
}

function ConvertDat(
    [string]$rctIdentifier,
    [string]$openRct2Identifier,
    [string]$customIdentifier
)
{
    $identifiers = $openRct2Identifier.Split(".")
    $originalGame = $identifiers[0]
    $objectType = $identifiers[1]
    $objectName = $identifiers[2]

    $newIdentifier = "$($namespace).$($objectType).$($objectName)"
    $objectPath = ".\objects\$($newIdentifier)"
    $imagePath = "$($objectPath)\images"
    $objectJson = "$($objectPath)\object.json"

    ExtractSprites $objectPath $imagePath $customIdentifier $rctIdentifier
    CopyData $openRct2bin $originalGame $objectType $openRct2Identifier $objectJson
    EditJson $openRct2Identifier $objectJson $newIdentifier

    Write-Host "Done"
}

$objects = @(`
[System.Tuple]::Create("TIC", "rct2.scenery_small.tic", "GWTRIC"), `
[System.Tuple]::Create("TLC", "rct2.scenery_small.tlc", "GWTRLC"), `
[System.Tuple]::Create("TMC", "rct2.scenery_small.tmc", "GWTRMC"), `
[System.Tuple]::Create("TMP", "rct2.scenery_small.tmp", "GWTRMP"), `
[System.Tuple]::Create("TITC", "rct2.scenery_small.titc", "GWTRITC"), `
[System.Tuple]::Create("TGHC", "rct2.scenery_small.tghc", "GWTRGHC"), `
[System.Tuple]::Create("TAC", "rct2.scenery_small.tac", "GWTRAC"), `
[System.Tuple]::Create("TGHC2", "rct2.scenery_small.tghc2", "GWTRHT"))

Write-Host "Converting $($objects.length) objects..."

for ($i = 0; $i -lt $objects.length; $i++)
{
    ConvertDat $objects[$i].Item1 $objects[$i].Item2 $objects[$i].Item3
}
