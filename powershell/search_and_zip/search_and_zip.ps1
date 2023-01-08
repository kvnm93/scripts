param (
    [string]$filePath
)

$4K_IDENTIFIER = "4K"
$8K_IDENTIFIER = "8K"

# Check if the file path is a directory
if (!(Test-Path $filePath -PathType Container)) {
    Write-Error "The file path specified is not a directory."
    return
}
Write-Output "Checked if file path is a directory."

# Search for files with "4K" or "8K" in the name
$files = Get-ChildItem $filePath | Where-Object {$_.Name -match $4K_IDENTIFIER -or $_.Name -match $8K_IDENTIFIER}
Write-Output "Searched for files with '$4K_IDENTIFIER' or '$8K_IDENTIFIER' in the name."

# Create a folder for each search parameter
foreach ($file in $files) {
    $folderName = $4K_IDENTIFIER
    $is4k = $file.Name -match $4K_IDENTIFIER
    if (!$is4k) {
        $folderName = $8K_IDENTIFIER
    }
    Write-Output  $file.Name -replace ".*($4K_IDENTIFIER|$8K_IDENTIFIER).*", "$1"
    $folderPath = Join-Path $filePath $folderName
    if (!(Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath
    }

    # Move the file to the appropriate folder
    $destination = Join-Path $folderPath $file.Name
    Move-Item -Path $file.FullName -Destination $destination
    Write-Output "Moved file '$($file.Name)' to folder '$folderName'."
}

# Zip the folders
$folders = Get-ChildItem $filePath | Where-Object {$_.PSIsContainer}
foreach ($folder in $folders) {
    $zipPath = "$($folder.FullName).zip"
    Compress-Archive -Path $folder.FullName -DestinationPath $zipPath
    Write-Output "Created zip archive '$zipPath'."
}