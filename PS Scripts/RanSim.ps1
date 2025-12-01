param(
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter(Mandatory)]
    [string[]]$Extension,

    [Parameter()]
    [switch]$Recurse,

    [Parameter()]
    [switch]$Decrypt
)

# Hardcoded AES-256 key and IV from "Orion_1234567890" (plaintext bytes, Base64 encoded)
$KeyPlaintext = 'Orion_1234567890'
$IVPlaintext  = 'Orion_1234567890'

# Derive 32-byte key and 16-byte IV from plaintext using UTF8 bytes + SHA256
$KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($KeyPlaintext) | ForEach-Object { $_ } | Select-Object -First 32
$IVBytes  = [System.Text.Encoding]::UTF8.GetBytes($IVPlaintext) | ForEach-Object { $_ } | Select-Object -First 16

$KeyBase64 = [Convert]::ToBase64String($KeyBytes)
$IVBase64  = [Convert]::ToBase64String($IVBytes)

function Invoke-RansomSimEncrypt {
    param(
        [string]$Path,
        [string[]]$Extension,
        [switch]$Recurse,
        [string]$KeyBase64,
        [string]$IVBase64
    )

    $keyBytes = [Convert]::FromBase64String($KeyBase64)
    $ivBytes  = [Convert]::FromBase64String($IVBase64)

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key     = $keyBytes
    $aes.IV      = $ivBytes
    $aes.Mode    = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

    $searchParams = @{ Path = $Path; File = $true }
    if ($Recurse) { $searchParams.Recurse = $true }

    $extNormalized = $Extension | ForEach-Object {
        if ($_ -notlike ".*") { ".$_" } else { $_ }
    }

    $files = Get-ChildItem @searchParams | Where-Object {
        $extNormalized -contains $_.Extension
    }

    foreach ($file in $files) {
        $inPath  = $file.FullName
        $outPath = "$inPath.enc"

        if (Test-Path -LiteralPath $outPath) {
            Write-Verbose "Skipping '$inPath' because '$outPath' exists."
            continue
        }

        $plainBytes  = [System.IO.File]::ReadAllBytes($inPath)
        $encryptor   = $aes.CreateEncryptor()
        $cipherBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
        [System.IO.File]::WriteAllBytes($outPath, $cipherBytes)
        Write-Output "Encrypted: $inPath -> $outPath"
    }
}

function Invoke-RansomSimDecrypt {
    param(
        [string]$Path,
        [switch]$Recurse,
        [string]$KeyBase64,
        [string]$IVBase64
    )

    $keyBytes = [Convert]::FromBase64String($KeyBase64)
    $ivBytes  = [Convert]::FromBase64String($IVBase64)

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key     = $keyBytes
    $aes.IV      = $ivBytes
    $aes.Mode    = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

    $searchParams = @{ Path = $Path; File = $true; Filter = '*.enc' }
    if ($Recurse) { $searchParams.Recurse = $true }

    $files = Get-ChildItem @searchParams

    foreach ($file in $files) {
        $inPath  = $file.FullName
        $outPath = $inPath -replace '\.enc$', ''

        if (Test-Path -LiteralPath $outPath) {
            Write-Verbose "Skipping '$inPath' because '$outPath' exists."
            continue
        }

        $cipherBytes = [System.IO.File]::ReadAllBytes($inPath)
        $decryptor   = $aes.CreateDecryptor()
        $plainBytes  = $decryptor.TransformFinalBlock($cipherBytes, 0, $cipherBytes.Length)
        [System.IO.File]::WriteAllBytes($outPath, $plainBytes)
        Write-Output "Decrypted: $inPath -> $outPath"
    }
}

if ($Decrypt) {
    Invoke-RansomSimDecrypt -Path $Path -Recurse:$Recurse -KeyBase64 $KeyBase64 -IVBase64 $IVBase64
} else {
    Invoke-RansomSimEncrypt -Path $Path -Extension $Extension -Recurse:$Recurse -KeyBase64 $KeyBase64 -IVBase64 $IVBase64
}
