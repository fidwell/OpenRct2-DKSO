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
$objectJson = "$($objectPath)\object.json"

function ExtractSprites
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

function CopyData
{
    Write-Host "Copying json..."
    $source = "$($openRct2bin)\data\object\$($originalGame)\$($objectType)\$($openRct2Identifier).json"
    Copy-Item $source -Destination $objectJson
}

function EditJson
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

ExtractSprites
CopyData
EditJson

Write-Host "Done"
  