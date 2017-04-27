Function Set-SCSMServiceRelatedItems
{
[CmdletBinding()]
Param(
    [string]$Path
)

try
    {
        $ImportedData = Import-Csv -Path $Path -ErrorAction STOP
    }
catch
    {
        Write-Error "CSV File does not exist"
        exit 1;
    }

#Constant
$BusinessServiceClass = Get-SCSMClass -Name "Microsoft.SystemCenter.BusinessService"
$ComputerGroupClass = Get-SCSMClass -Name "Microsoft.SystemCenter.Service.ComputersGroup"
$ComputerTypeClass = Get-SCSMClass -Name "Microsoft.Windows.Computer"
$ComputerGroupRealtionshipClassObject = Get-SCSMRelationship -Name "System.ConfigItemContainsConfigItem"

<#SampleData
$ImportedData = @{
    ServiceName = "SampleService"
    Computers = "CMTP-DC01"
}#>

foreach ($row in $ImportedData)
{
    $ServiceName = $row.ServiceName
    $Computers = $row.Computers

    $BusinessServiceClassObject = Get-SCSMClassInstance -Class $BusinessServiceClass -Filter "DisplayName -eq $ServiceName"
    $ServiceComputerRelationshipObject = Get-SCSMRelationshipInstance | Where-Object SourceObject -eq $BusinessServiceClassObject.EnterpriseManagementObject
    $ComputerGroupObject = Get-SCSMClassInstance -Id $ServiceComputerRelationshipObject.TargetObject.Id
    $ComputerObjects = (Get-SCSMRelationshipInstance | Where-Object {($_.SourceObject -eq $ComputerGroupObject.EnterpriseManagementObject) -and ($_.IsDeleted -ne $true)}).TargetObject.DisplayName

    $addObjects = @()
    $removeObjects = @()

    $SplitComputers = $Computers.Split(";")

    foreach ($obj in $SplitComputers)
        {
            if ($ComputerObjects -contains $obj){}
            else {$addObjects += $obj}
        }

    foreach ($obj in $ComputerObjects)
        {
            if ($SplitComputers -contains $obj) {}
            else {$removeObjects += $obj}
        }
    
    foreach ($obj in $addObjects)
        {
            $new = Get-SCSMClassInstance -Class $ComputerTypeClass -Filter "DisplayName -eq $obj"
            New-SCRelationshipInstance -RelationshipClass $ComputerGroupRealtionshipClassObject -Source $ComputerGroupObject -Target $new
        }

    foreach ($obj in $removeObjects)
        {
            $rel = Get-SCSMRelationshipInstance | Where-Object {($_.SourceObject -eq $ComputerGroupObject.EnterpriseManagementObject) -and ($_.IsDeleted -ne $true) -and ($_.TargetObject.DisplayName -eq $obj)}
            Remove-SCRelationshipInstance -Instance $rel
        }
    }
}