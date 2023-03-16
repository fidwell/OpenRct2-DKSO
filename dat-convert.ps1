if ($args.Length -lt 2)
{
    Write-Host "Usage: dat-convert RCT-IDENTIFIER openrct2.identifier CUSTOM-IDENTIFIER"
    return
}

$rctIdentifier = $args[0]
$openRct2Identifier = $args[1]
$customIdentifier = $args[2]

$documents = [Environment]::GetFolderPath("MyDocuments")
$openRct2bin = "$($documents)\OpenRct2\bin"
$openRct2com = "$($openRct2bin)\openrct2.com"

$namespace = "fidwell"
$identifiers = $openRct2Identifier.Split(".")
$originalGame = $identifiers[0]
$objectType = $identifiers[1]
$objectName = $identifiers[2]

$newIdentifier = "$($namespace).$($objectType).$($objectName)"
$objectPath = ".\objects\$($newIdentifier)"
$imagePath = "$($objectPath)\images"

function ExtractSprites
{
    New-Item -Path "$($objectPath)" -ItemType Directory -Force | Out-Null
    New-Item -Path "$($imagePath)" -ItemType Directory -Force | Out-Null

    $command = ""
    if ($customIdentifier.Length -eq 0)
    {
        Write-Host "Extracting vanilla object"
        $command = "$($openRct2com) sprite exportalldat $($rctIdentifier) $($imagePath) > $($objectPath)/images.json"
    }
    else
    {
        Write-Host "Extracting custom object"
        $command = "$($openRct2com) sprite exportalldat $($customIdentifier) $($imagePath) > $($objectPath)/images.json"
    }

    Invoke-Expression -Command $command
}

function CopyData
{
    $source = "$($openRct2bin)\data\object\$($originalGame)\$($objectType)\$($openRct2Identifier).json"
    
    Copy-Item $source -Destination "$($objectPath)\object.json"
}

function EditJson
{
    # To do
}

ExtractSprites
CopyData
EditJson
