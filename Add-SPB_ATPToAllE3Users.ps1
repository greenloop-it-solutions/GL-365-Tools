# Background: As a partner we have both MS 365 BP ("SBP") and MS 365 E3 licenses. The E3 contains more features, but inexplicably does not include Defender for 365 Plan 1 ("ATP_ENTERPRISE").
#
# This script adds ONLY the ATP_ENTERPRISE app plan to all users with an E3 subscription using the PowerShell Graph Module.
# Pre-requisites and getting started info here: https://docs.microsoft.com/en-us/powershell/microsoftgraph/installation
# v.1.0 S. Moody 2022-05-24

Connect-mgGraph -Scopes User.ReadWrite.All, Organization.Read.All

$mse3Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E3'
$mssbpSku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPB'

$users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($mse3Sku.SkuId) )" -ConsistencyLevel eventual -CountVariable e3licensedUserCount -All

Write-Host "Found $e3licensedUserCount E3 licensed users."

$EnabledPlans = 'ATP_ENTERPRISE'

$disabledPlans = $mssbpSku.ServicePlans | Where ServicePlanName -ne ('ATP_ENTERPRISE') | Select -ExpandProperty ServicePlanId

$addLicenses = @(
    @{
        SkuId = $mssbpSku.SkuId
        DisabledPlans = $disabledPlans
    }
)

foreach ($user in $users) {

    Set-MgUserLicense -UserId $($user.UserPrincipalName) -AddLicenses $addLicenses -RemoveLicenses @()
}
