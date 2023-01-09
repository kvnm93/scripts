# Import the System.IO.Compression.FileSystem assembly
Add-Type -AssemblyName System.IO.Compression.FileSystem

$IDENTIFIERS = @('8K', '4K', '2K', '1K')

function SearchAndZip {

    param (
        $filePath
    )

    Write-Output "Input path to process: $filePath"

    # Check if the file path is a directory
    if (!(Test-Path $filePath -PathType Container)) {
        Write-Error "The file path specified is not a directory."
        return
    }
    Write-Output "Checked if file path is a directory."

    foreach ($identifier in $IDENTIFIERS) {
        Write-Output "`n`n Identifier $identifier ------------------------------------------------------------"
        # Search for files with identifier in the name
        $files = Get-ChildItem $filePath | Where-Object {$_.Name -match $identifier}
        Write-Output "Searched for files with '$identifier' in the name."

        if ($files.length -gt 0) {
            # Zip folder gets name of the first file
            $firstFileName = $files[0].Name 
            $zipFileName = $firstFileName.replace('.png', '').replace('.jpg', '').replace('.jpeg', '').replace('_Albedo', '').replace('_AO', '').replace('_Height', '').replace('_Preview', '')

            if ($zipFileName -eq "") {
                continue
            }

            Write-Output "`n ZIP: Generated Zip Folder Name = $zipFileName`n"

            $zipPath = Join-Path $filePath "$zipFileName.zip"
            if (!(Test-Path $zipPath)) {
                [System.IO.Compression.ZipFile]::CreateFromDirectory($filePath, $zipPath)
            }
            
            # Add the files to the zip archive
            foreach ($file in $files) {
                Write-Output "`n File $($file.Name)-----------------------"
                $entryName = [System.IO.Path]::GetFileName($file.FullName)
                $zipStream = [System.IO.Compression.ZipFile]::Open($zipPath, 'Update')
                $fileStream = [System.IO.File]::OpenRead($file.FullName)
                $zipEntry = $zipStream.CreateEntry($entryName)
                $fileStream.CopyTo($zipEntry.Open())
                $zipStream.Dispose()
                Write-Output "Zipped file '$($file.Name)' to '$zipPath'."
            }

        } else {
            Write-Output "Did not find any files matching $identifier"
        }   

    }

}


$continue = $true

while ($continue) {
    # Get user input
    # $inputPath = Read-Host "Enter the file path of the folder `n you would like to scan as absolute path `n (e.g. C:\path\to\your\folder)`n"
    $inputPath = "C:\Users\kevin\Documents\GitHub\scripts\powershell\search_and_zip\file_test"


    # Echo input to the console
    SearchAndZip $inputPath

    # Prompt the user if they want to continue
    $response = Read-Host "Do you want to continue? (yes/no) "

    # Check the response
    if ($response -eq "no" -or $response -eq "n" -or $response -eq "NO" -or $response -eq "NO" ) {
        # Set the flag to false to exit the loop
        $continue = $false
    }
}

Write-Output "Exiting script..."


