$files = Get-ChildItem -Path "src" -Filter "*.cs" -Recurse
foreach ($file in $files) {
    $lines = Get-Content -Path $file.FullName
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match "IsActive") {
            Write-Host "$($file.Name):$($i + 1): $($lines[$i])"
        }
    }
}
