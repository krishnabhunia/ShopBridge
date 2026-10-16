#requires -Version 5.1
<#
  Disposable SQL Server LocalDB integration test for DB Scripts/setup-safe.sql.
  Creates and destroys its own LocalDB instance; never targets a shared SQL Server.
  Requires LocalDB runtime on the Windows host (GitHub Actions windows-2022 image).
#>
$ErrorActionPreference = 'Stop'

$localDbCmd = Get-Command 'SqlLocalDB.exe' -ErrorAction SilentlyContinue
$localDbExe = if ($localDbCmd) { $localDbCmd.Source } else {
    Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft SQL Server') -Recurse -Filter 'SqlLocalDB.exe' -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $localDbExe) { throw 'SqlLocalDB.exe not found: install SQL Server Express LocalDB before running this integration test.' }

$instanceName = 'ShopBridgeCI'
$connection = $null

function Invoke-NonQuery([string]$sql, [hashtable]$parameters = @{}) {
    $cmd = $connection.CreateCommand()
    try {
        $cmd.CommandText = $sql
        $cmd.CommandTimeout = 60
        foreach ($key in $parameters.Keys) {
            [void]$cmd.Parameters.AddWithValue("@$key", $parameters[$key])
        }
        return $cmd.ExecuteNonQuery()
    } finally { $cmd.Dispose() }
}

function Invoke-Scalar([string]$sql, [hashtable]$parameters = @{}) {
    $cmd = $connection.CreateCommand()
    try {
        $cmd.CommandText = $sql
        $cmd.CommandTimeout = 60
        foreach ($key in $parameters.Keys) {
            [void]$cmd.Parameters.AddWithValue("@$key", $parameters[$key])
        }
        return $cmd.ExecuteScalar()
    } finally { $cmd.Dispose() }
}

function Invoke-Bootstrap {
    $scriptPath = Join-Path $PSScriptRoot '..\DB Scripts\setup-safe.sql'
    $scriptText = [System.IO.File]::ReadAllText((Resolve-Path $scriptPath).Path)
    # GO is a client-side batch separator, not a Transact-SQL statement.
    foreach ($batch in ($scriptText -split '(?im)^\s*GO\s*$')) {
        if (-not [string]::IsNullOrWhiteSpace($batch)) {
            [void](Invoke-NonQuery $batch)
        }
    }
}

try {
    & $localDbExe create $instanceName | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Creating LocalDB instance failed.' }
    & $localDbExe start $instanceName | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Starting LocalDB instance failed.' }

    $connection = [System.Data.SqlClient.SqlConnection]::new(
        "Data Source=(localdb)\$instanceName;Initial Catalog=master;Integrated Security=True;Connection Timeout=60;"
    )
    $connection.Open()
    Invoke-Bootstrap

    # Confirm table and procedures exist before modifying data.
    if ([int](Invoke-Scalar "SELECT COUNT(*) FROM sys.tables WHERE name = 'product' AND schema_id = SCHEMA_ID('dbo')") -ne 1) {
        throw 'Product table was not created.'
    }
    foreach ($procName in @('list', 'p_addItem', 'p_updateItem', 'p_deleteItem')) {
        $found = Invoke-Scalar 'SELECT COUNT(*) FROM sys.procedures WHERE name = @name' @{ name = $procName }
        if ([int]$found -ne 1) { throw "Stored procedure missing: $procName" }
    }

    $testName = 'ShopBridge CI product'
    [void](Invoke-NonQuery 'EXEC dbo.p_addItem @name, @desc, @price' @{
        name = $testName; desc = 'Test fixture'; price = [decimal]25.00
    })
    $id = [int](Invoke-Scalar 'SELECT TOP (1) product_id FROM dbo.product WHERE name = @name ORDER BY product_id DESC' @{ name = $testName })
    if ($id -le 0) { throw 'p_addItem did not insert a product.' }

    # A second bootstrap must preserve existing rows (idempotency).
    Invoke-Bootstrap
    $count = [int](Invoke-Scalar 'SELECT COUNT(*) FROM dbo.product WHERE product_id = @id' @{ id = $id })
    if ($count -ne 1) { throw 'Second bootstrap deleted an existing row.' }

    [void](Invoke-NonQuery 'EXEC dbo.p_updateItem @product_id, @name, @desc, @price' @{
        product_id = $id; name = $testName; desc = 'Updated fixture'; price = [decimal]27.00
    })
    $price = [decimal](Invoke-Scalar 'SELECT price FROM dbo.product WHERE product_id = @id' @{ id = $id })
    if ($price -ne [decimal]27.00) { throw 'p_updateItem failed to update the price.' }

    $listed = [int](Invoke-Scalar 'EXEC dbo.[list]')
    if ($listed -ne $id) { throw 'list procedure did not return the inserted product.' }

    [void](Invoke-NonQuery 'EXEC dbo.p_deleteItem @product_id' @{ product_id = $id })
    if ([int](Invoke-Scalar 'SELECT COUNT(*) FROM dbo.product WHERE product_id = @id' @{ id = $id }) -ne 0) {
        throw 'p_deleteItem did not delete the test product.'
    }

    Write-Host 'PASS: SQL bootstrap, repeat-run row preservation, and list/add/update/delete stored procedures.'
} finally {
    if ($connection) { $connection.Dispose() }
    & $localDbExe stop $instanceName -k 2>&1 | Out-Null
    & $localDbExe delete $instanceName 2>&1 | Out-Null
}
