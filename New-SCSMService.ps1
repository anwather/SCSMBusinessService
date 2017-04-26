Function Set-SCSMService
{
    [CmdletBindin()]
    Param([string]$Path)
try
    {
        $importFields = Import-Csv -Path $Path -ErrorAction STOP
    }
catch
    {
        Write-Error "CSV File does not exist"
        exit 1;
    }
    
    $class = Get-SCSMClass -Name "Microsoft.SystemCenter.BusinessService"
    $serviceRel = Get-SCSMRelationshipClass -Name "System.ConfigItemContainsConfigItem"
    
foreach ($service in $importFields)
    {
    if ($service.RelatedService -ne $null)
        {
        
        $bServiceGroup = Get-SCSMObject -Class $class -Filter "DisplayName -eq ""$($service.DisplayName)"""
        
        $bServiceObjects = Get-SCSMRelationshipObject -Relationship $serviceRel | Where-Object {($_.TargetObject).DisplayName -eq $service.DisplayName}
        
        $bServiceArray = @()
        
        foreach ($obj in $bServiceObjects)
            {
                $bServiceArray += ($obj.SourceObject).DisplayName
            }
        
        $addObjects = @()
        $removeObjects = @()
        
        $splitRelatedService = ($service.RelatedService).Split(";")
        
        #Compare Objects
        
        foreach ($relatedService in $splitRelatedService)
            {
            if ($bserviceArray -contains $relatedService)
                {}
            else
                {
                $addObjects += $relatedService
                }
            }
        foreach ($bservice in $bServiceArray)
            {
            if ($splitRelatedService -contains $bService)
                {}
            else
                {
                $removeObjects += $bservice
                }
            }
            
         # Add or remove objects
         
         foreach ($obj in $addObjects)
            {
            $newServiceGroup = Get-SCSMObject -Class $class -Filter "DisplayName -eq $obj"
            $rel = New-SCSMRelationshipObject -Relationship $serviceRel -Source $newServiceGroup -Target $bServiceGroup -Bulk -PassThru
            }
            
         foreach ($obj in $removeObjects)
            {
            $newServiceGroup = Get-SCSMObject -Class $class -Filter "DisplayName -eq $obj"
            $rel = Get-SCSMRelationshipObject -Relationship $serviceRel | Where-Object {($($_.SourceObject).DisplayName -eq $($newServiceGroup.DisplayName)) -and ($($_.TargetObject).DisplayName -eq $($bServiceGroup.DisplayName))}
            $rem = Remove-SCSMRelationshipObject -SMObject $rel
            }
        
        }
    }
}

Function New-SCSMService
{
      [CmdletBindin()]
      Param([string]$Path)
    
try
    {
        $importFields = Import-Csv -Path $Path -ErrorAction STOP
    }
catch
    {
        Write-Error "CSV File does not exist"
        exit 1;
    }

foreach ($service in $importFields)
    {
    
   #Determine if the service exists
   
   $class = Get-SCSMClass -Name "Microsoft.SystemCenter.BusinessService"
   #$groupClass = Get-SCSMClass -Name "System.Domain.User"
  # $serviceOwnerClass = Get-SCSMRelationshipClass -Name "System.ConfigItemOwnedByUser"
   #$serviceCustomerClass = Get-SCSMRelationshipClass -Name "System.ServiceImpactsUser"
   
   $guid = [guid]::NewGuid()
   
   # Create the object if it doesn't exist
   if (!(Get-SCSMObject -Class $class -Filter "DisplayName -eq ""$($service.DisplayName)"""))
    {
    $props = @{
        "DisplayName" = $service.DisplayName
        #"Classification" = $service.Classification 
        #"Priority" = $service.Priority
        #"Status" = $service.Status
        #"ServiceID" = $guid.ToString()
       # "Organization" = $service.Organization
       # "Availability" = $service.Availability
        }
    $obj = New-SCSMObject -Class $class -PropertyHashtable $props -PassThru
    
    #$serviceOwnerObj = Get-SCSMObject -Class $groupClass -Filter "UserName -eq ""$($service.ServiceOwner)"""
    
   # $serviceOwnerRel = New-SCSMRelationshipObject -Relationship $serviceOwnerClass -Source $obj -Target $serviceOwnerObj -Bulk -PassThru
    
    #$serviceCustomerObj = Get-SCSMObject -Class $groupClass -Filter "UserName -eq ""$($service.ServiceCustomer)"""
    
    #$serviceCustomerRel = New-SCSMRelationshipObject -Relationship $serviceCustomerClass -Source $obj -Target $serviceCustomerObj -Bulk -PassThru
    }
    }
    
    
    
}
    