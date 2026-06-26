$connectionString = "Server=DESKTOP-HO6596P\SQLEXPRESS;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"
$sqlFile = "database/09_staff_and_fees_procedures.sql"

Write-Host "Reading SQL Script..."
$script = Get-Content -Path $sqlFile -Raw

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
    Write-Host "[SUCCESS] Stored procedures successfully deployed!"
}
catch {
    Write-Error "Deployment failed: $_"
    if ($command -and $command.CommandText) {
        Write-Host "Failed Batch:"
        Write-Host $command.CommandText
    }
}
finally {
    $connection.Close()
}
