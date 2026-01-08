function trasnfer {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, Position=0)]
        [string]$InputObject,

        [Parameter(Position=1)]
        [string]$FileName
    )

    # Ensure qrCodeGenerator module is available
    if (-not (Get-Module -ListAvailable -Name qrCodeGenerator)) {
        Install-Module -Name qrCodeGenerator -Force -Scope CurrentUser
    }
    Import-Module qrCodeGenerator

    begin {
        $pipedList = @()
    }

    process {
        if ($null -ne $InputObject) {
            $pipedList += $InputObject
        }
    }

    end {
        if (-not $InputObject -and -not $pipedList -and -not $FileName) {
            Write-Error "No arguments specified.`nUsage:`n trasnfer <file|directory>`n ... | trasnfer <file_name>"
            return 1
        }

        # Determine upload scenario
        if ($FileName) {
            # Piped input scenario
            $inputData = $pipedList -join "`n"
            $tempFile = [System.IO.Path]::GetTempFileName()
            [System.IO.File]::WriteAllText($tempFile, $inputData)

            try {
                $uploadUrl = "https://transfer.whalebone.io/$FileName"
                curl.exe --progress-bar --upload-file $tempFile $uploadUrl | Out-Null
            } finally {
                Remove-Item $tempFile -Force
            }
        } else {
            # Direct file/directory scenario
            $Path = $InputObject
            if (-not (Test-Path $Path)) {
                Write-Error "$Path: No such file or directory"
                return 1
            }

            $fileName = Split-Path $Path -Leaf
            if (Test-Path $Path -PathType Container) {
                # Directory - zip it
                $zipFileName = "$fileName.zip"
                $tempZipPath = Join-Path $env:TEMP $zipFileName
                Compress-Archive -Path $Path -DestinationPath $tempZipPath -Force
                $Path = $tempZipPath
                $fileName = $zipFileName
            }

            $uploadUrl = "https://transfer.whalebone.io/$fileName"
            curl.exe --progress-bar --upload-file $Path $uploadUrl | Out-Null

            # Remove temp zip if created
            if (Test-Path $tempZipPath) {
                Remove-Item $tempZipPath -Force
            }
        }

        # Print QR code in terminal
        $uploadUrl | New-QRCode -AsAscii

        # Return the uploaded URL
        $uploadUrl
    }
}
