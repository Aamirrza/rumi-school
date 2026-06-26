$connectionString = "Server=DESKTOP-HO6596P\SQLEXPRESS;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"

function Execute-SqlScript ($filePath) {
    Write-Host "Reading SQL Script: $filePath ..."
    $script = Get-Content -Path $filePath -Raw
    
    # Split the script into batches by GO statements
    $batches = [System.Text.RegularExpressions.Regex]::Split($script, "(?i)^\s*GO\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    
    Write-Host "Connecting to SQL Server..."
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    Write-Host "Executing script batches..."
    try {
        foreach ($batch in $batches) {
            $trimmedBatch = $batch.Trim()
            if ($trimmedBatch.Length -gt 0) {
                $command = $connection.CreateCommand()
                $command.CommandText = $trimmedBatch
                $null = $command.ExecuteNonQuery()
            }
        }
        Write-Host "[SUCCESS] Deployed $filePath successfully!"
    }
    catch {
        $err = $_
        Write-Error "Deployment failed for ${filePath}. Error: $err"
        if ($command -and $command.CommandText) {
            Write-Host "Failed Batch:"
            Write-Host $command.CommandText
        }
        throw $err
    }
    finally {
        $connection.Close()
    }
}

Execute-SqlScript "C:\Users\Steve\.gemini\antigravity\scratch\sms-mvc\scratch\alter_photo_to_binary.sql"
Execute-SqlScript "C:\Users\Steve\.gemini\antigravity\scratch\sms-mvc\database\09_staff_and_fees_procedures.sql"
Execute-SqlScript "C:\Users\Steve\.gemini\antigravity\scratch\sms-mvc\scratch\fix_getbyid_procedure.sql"
# Execute-SqlScript "C:\Users\Steve\.gemini\antigravity\scratch\sms-mvc\scratch\seed_additional_data.sql"
