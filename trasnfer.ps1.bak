function trasnfer {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, Position=0)]
        [string]$InputObject,

        [Parameter(Position=1)]
        [string]$FileName
    )

    # Process block to handle piped input
    begin {
        $pipedList = @()
    }

    process {
        if ($null -ne $InputObject) {
            $pipedList += $InputObject
        }
    }

    end {
        # Check if we have piped input without a filename (meaning we're receiving piped data)
        $isPipedInput = $pipedList.Count -gt 0 -and -not $FileName

        if (-not $InputObject -and -not $FileName) {
            Write-Error "No arguments specified.`nUsage:`n trasnfer <file|directory>`n ... | trasnfer <file_name>"
            return 1
        }

        if ($isPipedInput) {
            # This scenario shouldn't happen based on our parameter setup,
            # but handling for completeness
            Write-Error "Filename required when piping data.`nUsage: ... | trasnfer <file_name>"
            return 1
        }

        if ($FileName) {
            # Input from pipeline - upload with specified filename
            # Join all piped input into a single string
            $inputData = $pipedList -join "`n"

            # Create a temporary file for the piped content
            $tempFile = [System.IO.Path]::GetTempFileName()
            [System.IO.File]::WriteAllText($tempFile, $inputData)

            try {
                $uploadUrl = "https://transfer.whalebone.io/$FileName"
                $result = curl.exe --progress-bar --upload-file $tempFile $uploadUrl
                Write-Output $result
            } finally {
                Remove-Item $tempFile -Force
            }
        } else {
            # Input from terminal - process file or directory
            $Path = $InputObject

            if (-not (Test-Path $Path)) {
                Write-Error "$Path: No such file or directory"
                return 1
            }

            $fileName = Split-Path $Path -Leaf

            if (Test-Path $Path -PathType Container) {
                # Directory - zip it first
                $zipFileName = "$fileName.zip"
                $tempZipPath = Join-Path $env:TEMP $zipFileName

                # Use PowerShell's Compress-Archive to create zip
                Compress-Archive -Path $Path -DestinationPath $tempZipPath -Force

                try {
                    $uploadUrl = "https://transfer.whalebone.io/$zipFileName"
                    $result = curl.exe --progress-bar --upload-file $tempZipPath $uploadUrl
                    Write-Output $result
                } finally {
                    Remove-Item $tempZipPath -Force
                }
            } else {
                # Regular file - upload directly
                $uploadUrl = "https://transfer.whalebone.io/$fileName"
                $result = curl.exe --progress-bar --upload-file $Path $uploadUrl
                Write-Output $result
            }
        }

        Write-Output ""
        Write-Output ""
    }
}