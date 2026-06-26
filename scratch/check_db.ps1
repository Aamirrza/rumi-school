$connectionString = "Server=DESKTOP-HO6596P\SQLEXPRESS;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "exec sp_helptext 'usp_Student_GetById'"
try {
    $r = $cmd.ExecuteReader()
    while ($r.Read()) {
        Write-Host $r[0] -NoNewline
    }
    $r.Close()
} catch {
    Write-Host "Failed: $_"
}

$conn.Close()
