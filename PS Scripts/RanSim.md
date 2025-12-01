# Usage Examples

## Execute directly from web:
```
& ([scriptblock]::Create((irm https://example.com/script.ps1))) -Path "C:\Test" -Extensions @("txt","doc","pdf") -Recurse
```

## Local execution:

```
.\script.ps1 -Path "C:\Users\test\Documents" -Extensions "txt","docx" -Recurse:$true
```

> Make sure to change link and path