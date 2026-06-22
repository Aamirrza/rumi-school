$files = @(
    "C:\Users\Steve\.gemini\antigravity\scratch\sms-mvc\database\schema_and_seed.sql",
    "C:\Users\Steve\.gemini\antigravity\scratch\sms-mvc\database\08_create_stored_procedures.sql"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Replace StudentPhotoPath with StudentPhoto
        $content = $content -replace 'StudentPhotoPath', 'StudentPhoto'
        
        # Fix the data type in table creation
        $content = $content -replace 'StudentPhoto VARCHAR\(500\)', 'StudentPhoto VARBINARY(MAX)'
        
        # Fix the parameter in usp_Student_Save
        $content = $content -replace '@StudentPhoto VARCHAR\(500\) = NULL', '@StudentPhoto VARBINARY(MAX) = NULL'
        
        Set-Content $file -Value $content -Encoding Utf8
        Write-Host "Processed $file"
    } else {
        Write-Warning "File not found: $file"
    }
}
