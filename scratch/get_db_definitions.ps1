$connectionString = "Server=DESKTOP-HO6596P\SQLEXPRESS;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

$outputFile = "C:\Users\Steve\.gemini\antigravity\scratch\sms-mvc\scratch\definitions_output.txt"
$writer = New-Object System.IO.StreamWriter($outputFile, $false)

function Log($text) {
    $writer.WriteLine($text)
}

function Get-ObjectDefinition($name) {
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('$name'))"
    $val = $cmd.ExecuteScalar()
    return $val
}

# 1. Get altered tables columns for StudentInfo
$cmd = $connection.CreateCommand()
$cmd.CommandText = "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'StudentInfo'"
$reader = $cmd.ExecuteReader()
Log("--- Table StudentInfo Columns ---")
while ($reader.Read()) {
    Log(($reader["COLUMN_NAME"].ToString() + " " + $reader["DATA_TYPE"].ToString() + " (" + $reader["CHARACTER_MAXIMUM_LENGTH"].ToString() + ")"))
}
$reader.Close()

# 2. Get views and SPs definition
$objects = @("vw_StudentDetails", "usp_Student_Save", "usp_Student_GetById", "usp_Student_GetAll", "usp_Student_Search")
foreach ($obj in $objects) {
    Log("`n========================================================")
    Log("--- Object: $obj ---")
    Log("========================================================")
    $def = Get-ObjectDefinition $obj
    Log($def)
}

$writer.Close()
$connection.Close()
Write-Host "Done writing definitions to $outputFile"
