$connectionString = "Server=DESKTOP-HO6596P\SQLEXPRESS;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Student_GetById')) AS sp_def"
$def = $command.ExecuteScalar()
Write-Host $def
$connection.Close()
