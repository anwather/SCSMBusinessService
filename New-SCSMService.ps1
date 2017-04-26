try
    {
        $importFields = Import-Csv -Path "D:\_Source Files\Business Service List\bs.csv" -ErrorAction STOP
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
        
        $bServiceObjects = Get-SCSMRelationshipObject -Relationship $serviceRel | Where {($_.TargetObject).DisplayName -eq $service.DisplayName}
        
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
            $newServiceGroup = get-SCSMObject -Class $class -Filter "DisplayName -eq $obj"
            $rel = New-SCSMRelationshipObject -Relationship $serviceRel -Source $newServiceGroup -Target $bServiceGroup -Bulk -PassThru
            }
            
         foreach ($obj in $removeObjects)
            {
            $newServiceGroup = Get-SCSMObject -Class $class -Filter "DisplayName -eq $obj"
            $rel = Get-SCSMRelationshipObject -Relationship $serviceRel | Where {($($_.SourceObject).DisplayName -eq $($newServiceGroup.DisplayName)) -and ($($_.TargetObject).DisplayName -eq $($bServiceGroup.DisplayName))}
            $rem = Remove-SCSMRelationshipObject -SMObject $rel
            }
        
        }
    }
    