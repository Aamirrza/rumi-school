$connectionString = "Server=DESKTOP-HO6596P\SQLEXPRESS;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = "SELECT name FROM sys.columns WHERE object_id = OBJECT_ID('vw_StudentDetails')"
$reader = $command.ExecuteReader()
while ($reader.Read()) {
    Write-Host $reader["name"]
}
$connection.Close()
