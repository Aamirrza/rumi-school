$connectionString = "Server=DESKTOP-HO6596P\SQLEXPRESS;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = "UPDATE Users SET PasswordHash = 'AQAAAAEAACcQAAAAEL/5rBAXlEOyPr8qkI3zrkG9s7dxmeW1CavmFnI9hhntrdub38kMW0xsNBhNLh5X3A==' WHERE Username = 'admin'"
$rows = $command.ExecuteNonQuery()
Write-Host "Updated $rows row(s)."
$connection.Close()
