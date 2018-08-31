# FQDN for the dynamic IP
$dynDNS = "home.kammermanns.ch"
# Azure Resource Group to be used
$nameRG = "AzureNetGroup"
# Name of the Azure Local Network Gateway
$nameLNG = "BlossomNet"

# Use Azure MSI to log into the Azure tenant
Add-AzureRmAccount -identity

# Get the current dynamic IP
[string]$dynIP = ([System.Net.DNS]::GetHostAddresses($dynDNS)).IPAddressToString
# Grab the current Local Network Gateway
$localNG = Get-AzureRmLocalNetworkGateway -ResourceName $nameLNG -ResourceGroupName $nameRG
# Output the IPs
Write-Host "Current Local Network Gateway IP:" $localNG.GatewayIPAddress
Write-Host "Current Dynamic IP:" $dynIP

# Determine if Gateway IP needs update
If ($dynIP -ne $localNG.GatewayIpAddress) {
    Write-Host "Dynamic IP is different to Local Network Gateway IP ... updating"
    # Update the Local Network Gateway
    $localNG.GatewayIpAddress = $dynIP
    Set-AzureRmLocalNetworkGateway -LocalNetworkGateway $localNG
}
else {
    Write-Host "No changes required"
}