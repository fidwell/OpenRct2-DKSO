$documents = [Environment]::GetFolderPath("MyDocuments")
$openRct2bin = "$($documents)\OpenRct2\bin"
$openRct2com = "$($openRct2bin)\openrct2.com"

$namespace = "fidwell"

function ExtractSprites(
    [string]$objectPath,
    [string]$imagePath,
    [string]$customIdentifier,
    [string]$rctIdentifier,
    [string]$imagesJson)
{
    Write-Host "Creating directories..."
    New-Item -Path $objectPath -ItemType Directory -Force | Out-Null
    New-Item -Path $imagePath -ItemType Directory -Force | Out-Null

    $command = ""
    $shouldRecolour = $false
    if ($customIdentifier.Length -eq 0)
    {
        Write-Host "Extracting vanilla object..."
        $command = "$($openRct2com) sprite exportalldat $($rctIdentifier.ToUpper()) $($imagePath) > $($imagesJson)"
        $shouldRecolour = $true
    }
    else
    {
        Write-Host "Extracting custom object..."
        $command = "$($openRct2com) sprite exportalldat $($customIdentifier.ToUpper()) $($imagePath) > $($imagesJson)"
    }

    Invoke-Expression -Command $command
    
    if ($shouldRecolour) {
        Write-Host "Recolouring vanilla object..."
        $files = Get-ChildItem $imagePath -Filter *.png
        Set-Location ./colourizer
        foreach ($f in $files) {
            java RecolourRctImage $f.FullName
        }
        Set-Location ..
    }
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
    [string]$newIdentifier,
    [string]$groupId,
    [string]$imagesJson)
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
    
    # Update images.json for manual editing
    (Get-Content $imagesJson) -replace "./objects/$($groupId)/$($newIdentifier)/", "" | Set-Content $imagesJson
}

function ConvertDat(
    [string]$groupId,
    [string]$openRct2Identifier,
    [string]$customIdentifier
)
{
    $identifiers = $openRct2Identifier.Split(".")
    $originalGame = $identifiers[0]
    $objectType = $identifiers[1]
    $objectName = $identifiers[2]

    $newIdentifier = "$($namespace).$($objectType).$($objectName)"
    $objectPath = ".\objects\$($groupId)\$($newIdentifier)"
    $imagePath = "$($objectPath)\images"
    $objectJson = "$($objectPath)\object.json"
    $imagesJson = "$($objectPath)\images.json"

    ExtractSprites $objectPath $imagePath $customIdentifier $objectName $imagesJson
    CopyData $openRct2bin $originalGame $objectType $openRct2Identifier $objectJson
    EditJson $openRct2Identifier $objectJson $newIdentifier $groupId $imagesJson

    Write-Host "Done"
}

if ($args.length -gt 1) {
    Write-Host "Converting a single object..."
    ConvertDat $args[0] $args[1] $args[2]
} else {
    Write-Host "Usage: dat-convert groupId openRct2Identifier [customIdentifier]"
}
