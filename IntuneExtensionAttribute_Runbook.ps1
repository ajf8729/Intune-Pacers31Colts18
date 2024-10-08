 # Variables
$tenantId = Get-AutomationVariable -Name 'TenantId'
$clientId = Get-AutomationVariable -Name 'ClientId'
$clientSecret = Get-AutomationVariable -Name 'ClientSecret'
 

 $tenantId = $tenantId
    $connectionDetails = @{
        resource      = 'https://graph.microsoft.com'
        client_id     = $clientid
        client_secret = $clientsecret
        grant_type    = "client_credentials"
        scope         = "openid"
    }

    $auth = Invoke-RestMethod -Method post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $connectionDetails
    $token = $auth.access_token

    $authHeader = @{
        'Authorization' = "Bearer $($token)"
        "ocp-client-name" = "Intune Web App"
        "ocp-client-version" = "1.0"
    }


#Get Remediation Script Output
$scriptName = "ALL_WIN_D_Detection_Domain_DEV"

$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts?" + '$filter=' + "startswith(displayName,'$scriptName')"
$result = Invoke-RestMethod -Uri $uri -Headers $authheader -Method GET

$scriptId= $result.value[0].id

$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts" + "/$scriptId/deviceRunStates/" + '?$expand=*'
$result = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET


$result.value | ForEach-Object {
$attribute = $_.preRemediationDetectionScriptOutput
$devicename = $_.manageddevice.devicename
$deviceid = $_.manageddevice.id


$json = @{
    "extensionAttributes" = @{
    "extensionAttribute1" = $attribute
    }
    } | ConvertTo-Json

#Update Device with $attribute Output

$uri = 'https://graph.microsoft.com/beta/devices?$filter=displayName eq '+ "'$devicename'"
$result = Invoke-RestMethod -Uri $uri -Headers $authheader -Method Get
$deviceid = $($result.value[0].id)
$deviceuri = "https://graph.microsoft.com/beta/devices/$deviceid"

Invoke-RestMethod -Uri $deviceuri -Body $json -Method PATCH -ContentType "application/json" -Headers $authHeader
}