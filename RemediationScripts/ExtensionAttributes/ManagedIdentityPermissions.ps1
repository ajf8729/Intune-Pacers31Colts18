$SP_ID = '8ea4ac2d-087c-4bcc-bb8e-8ccd0e385317' #Replace with ID
$AppId = (Get-MgServicePrincipal -ServicePrincipalId $SP_ID).AppId

# Connect with scopes requried to grant permissions
# May require admin consent for Graph PowerShell
Connect-MgGraph -Scopes appRoleAssignment.ReadWrite.All,Application.Read.All,Group.ReadWrite.All

# Grant Device.ReadWrite.All Graph Permissions
"DeviceManagementManagedDevices.Read.All" | ForEach-Object {
   $PermissionName = $_
   $GraphSP = Get-MgServicePrincipal -Filter "startswith(DisplayName,'Microsoft Graph')" | Select-Object -first 1 #Graph App ID: 00000003-0000-0000-c000-000000000000
   $AppRole = $GraphSP.AppRoles | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}
   New-MgServicePrincipalAppRoleAssignment -AppRoleId $AppRole.Id -ServicePrincipalId $SP_ID -ResourceId $GraphSP.Id -PrincipalId $SP_ID
}
