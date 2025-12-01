param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$true)]
    [string[]]$Extensions,
    
    [switch]$Recurse
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

# Find matching files
$files = Get-ChildItem -Path $Path -Recurse:$Recurse -File | 
         Where-Object { $Extensions -contains $_.Extension.TrimStart('.') }

foreach ($file in $files) {
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $encryptedBytes = $encryptor.TransformFinalBlock($fileBytes, 0, $fileBytes.Length)
        
        $encryptedPath = $file.FullName + ".orn"
        [System.IO.File]::WriteAllBytes($encryptedPath, $encryptedBytes)
        
        # Optionally delete original (uncomment if desired)
        # Remove-Item $file.FullName -Force
        
        Write-Host "Encrypted: $($file.Name) -> $encryptedPath"
    }
    catch {
        Write-Warning "Failed to encrypt $($file.Name): $_"
    }
}

$aes.Dispose()
Write-Host "Encryption complete. Processed $($files.Count) files." [web:1][web:8]
