#Variables to Modify
$scriptName = "JoeLoveless - ExtensionAttributes - OrganizationalUnit"
$appregistrationName = "JoeLoveless-Intune-ExtensionAttributes"
$extensionAttribute = "extensionAttribute2"

# Connect to the Graph API
Connect-MgGraph -Identity

$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts?" + '$filter=' + "startswith(displayName,'$scriptName')"
$result = Invoke-MgGraphRequest -uri $uri -Method GET

$scriptId= $result.value[0].id

$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts" + "/$scriptId/deviceRunStates/" + '?$expand=*'
$result = Invoke-MgGraphRequest -uri $uri -Method GET

$result.value | ForEach-Object {
$attribute = $_.preRemediationDetectionScriptOutput
$devicename = $_.manageddevice.devicename
$deviceid = $_.manageddevice.id

$json = @{
    "extensionAttributes" = @{
    $extensionAttribute = $attribute
    }
    } | ConvertTo-Json

#Update Device with $attribute Output

$uri = 'https://graph.microsoft.com/beta/devices?$filter=displayName eq '+ "'$devicename'"
$result = Invoke-MgGraphRequest -uri $uri -Method GET
$deviceid = $($result.value[0].id)
$deviceuri = "https://graph.microsoft.com/beta/devices/$deviceid"

Invoke-MgGraphRequest -uri $deviceuri -Body $json -Method PATCH -ContentType "application/json"
}