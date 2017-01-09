param(
    [Parameter(Mandatory)]$record,
    [Parameter(Mandatory=$false)]$type = "A",
    [Parameter(Mandatory)]$target,
    [Parameter(Mandatory=$false)]$TTL = 300,
    [Parameter(Mandatory)]$zone
)
$zoneEntry = (Get-R53HostedZones) | ? {$_.Name -eq "$($zone)."}
if (@($zoneEntry).count -eq 1) {
    $hostedZone = $zoneEntry.Id
    $Changes = (New-Object -TypeName System.Collections.ArrayList($null))
    $DNSName = "$($record).$($zone)"
    $RecordType = "$type"
    $DNSTarget = $target


    $change = New-Object Amazon.Route53.Model.Change
    $change.Action = "UPSERT"
    $change.ResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
    $change.ResourceRecordSet.Name = $DNSName
    $change.ResourceRecordSet.Type = $RecordType
    $change.ResourceRecordSet.TTL = $TTL
    $change.ResourceRecordSet.ResourceRecords.Add(@{Value=$DNSTarget})


    $params = @{
        HostedZoneId=$hostedZone
        ChangeBatch_Comment="Adding new A record for a school/parish for URL $DNSName to point to $DNSTarget"
        ChangeBatch_Change=$change
    }
    
    Edit-R53ResourceRecordSet @params
}
else {Write-Host "Zone name '$zone' not found"}