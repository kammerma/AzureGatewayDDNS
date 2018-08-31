#Set parameters
$connectionName = "AzureRunAsConnection"
$dynamicFQDN = "home.juds.ch"
$resourceGroup = "AzureNetGroup"
$gatewayName = "BlossomNet"

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
$message = "Current Dynamic IP: " + $dynamicIP
Write-Output $message
$localGateway = Get-AzureRmLocalNetworkGateway -ResourceName $gatewayName -ResourceGroupName $resourceGroup
$message = "Current Local Network Gateway IP: " + $localGateway.GatewayIPAddress
Write-Output $message

#Determine if gateway IP needs update
If ($dynamicIP -ne $localGateway.GatewayIpAddress) {
    Write-Output "Dynamic IP is different to Local Network Gateway IP ... updating"
    $localGateway.GatewayIpAddress = $dynamicIP
    Set-AzureRmLocalNetworkGateway -LocalNetworkGateway $localGateway
}
else {
    Write-Output "No changes required"
}