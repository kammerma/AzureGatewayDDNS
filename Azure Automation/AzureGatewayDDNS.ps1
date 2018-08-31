#Set parameters
Param
(
  [Parameter (Mandatory= $true)]
  [String] $dynamicFQDN,
  [Parameter (Mandatory= $false)]
  [String] $resourceGroup = "AzureNetGroup",
  [Parameter (Mandatory= $false)]
  [String] $gatewayName = "BlossomNet"
)
$connectionName = "AzureRunAsConnection"

#Log in to Azure
try
{
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-null
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found"
        throw $ErrorMessage
    } else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#Get the current IPs (local dynamic & gateway)
[string]$dynamicIP = ([System.Net.DNS]::GetHostAddresses($dynamicFQDN)).IPAddressToString
Write-Output "Current Dynamic IP: $dynamicIP"
$localGateway = Get-AzureRmLocalNetworkGateway -ResourceName $gatewayName -ResourceGroupName $resourceGroup
Write-Output "Current Local Network Gateway IP: $($localGateway.GatewayIPAddress)"

#Determine if gateway IP needs update
If ($dynamicIP -ne $localGateway.GatewayIpAddress) {
    Write-Output "Dynamic IP is different to Local Network Gateway IP ... updating"
    $localGateway.GatewayIpAddress = $dynamicIP
    Set-AzureRmLocalNetworkGateway -LocalNetworkGateway $localGateway | Out-null
}
else {
    Write-Output "No changes required"
}