#------------------------------------------------------------------------------   
#   
#    
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT   
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT   
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS   
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR    
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.   
#   
#------------------------------------------------------------------------------  

Write-host "This script will add routes for the selected Azure service in an existing UDR. Updating Routes can case routing issues.`
Please proceed if you are aware of the resulting routing." -ForegroundColor Green

$rg = Read-Host "Resource Group Name"
$UDR = Read-Host "Name of the UDR"

# To get all Public Address Prefixes 
$sertag = Get-AzNetworkServiceTag -Location eastus2

#Please note that the Azure region information you specify will be used as a reference for version (not as a filter based on location). 
#For example, even if you specify -Location eastus2 you will get the list of service tags with prefix details across all regions but limited to the cloud that your subscription belongs to (i.e. Public, US government, China or Germany).
#REF: https://docs.microsoft.com/en-us/powershell/module/az.network/get-aznetworkservicetag?view=azps-3.0.0

# Get the Address Prefixes for a service
$GetServiceName = $sertag.Values.Name | Out-GridView -OutputMode Single 

$GetServiceDetails = $sertag.Values | Where-Object { $_.Name -eq "$GetServiceName" }
#$ServiceName = $sertag.Values | Where-Object { $_.Name -eq "AzureActiveDirectory" }


#Get all IPs for that service
$Prefixes = $GetServiceDetails.Properties.AddressPrefixes

#To count the number Routes 
$Prefixes.count
$c = $Prefixes.count

if($c -gt '400'){Write-Host "User-defined routes per route table Limit: 400 (on 8 Dec 2020)"}
Else{Write-Host "Number of Routes to be added: $($c)"}


$nexthoptype = Read-Host "Enter the corresponding number for the next hop: `n 1.Internet `n 2.None `n 3.VirtualAppliance `n 4.VirtualNetworkGateway `n 5.VnetLocal `n Enter Next Hop Value:"
if($nexthoptype -eq 1){$nexthoptype = 'Internet'}
if($nexthoptype -eq 2){$nexthoptype = 'None'}
if($nexthoptype -eq 3){$nexthoptype = 'VirtualAppliance'}
if($nexthoptype -eq 4){$nexthoptype = 'VirtualNetworkGateway'}
if($nexthoptype -eq 5){$nexthoptype = 'VnetLocal'}
#$nexthoptype
if($nexthoptype -eq 'VirtualAppliance'){$nexthopIP = Read-Host "Enter IP address of the NVA"




# Create route for each prefix individually with Next Hop type as "Internet", you can change it as per your requirement
for ($i=0; $i -lt $c; $i++){ 
$Prefixes[$i]
$RT = Get-AzRouteTable -ResourceGroupName "$rg" -Name $UDR
$RTC = Add-AzRouteConfig -Name "$($GetServiceName)$($i)" -AddressPrefix $Prefixes[$i] -NextHopType $nexthoptype -NextHopIpAddress $nexthopIP -RouteTable $RT  
$rtc | Set-AzRouteTable
}

}
Else{
# Create route for each prefix individually with Next Hop type as "Internet", you can change it as per your requirement
for ($i=0; $i -lt $c; $i++){ 
$Prefixes[$i]
$RT = Get-AzRouteTable -ResourceGroupName "$rg" -Name $UDR
$RTC = Add-AzRouteConfig -Name "$($GetServiceName)$($i)" -AddressPrefix $Prefixes[$i] -NextHopType Internet -RouteTable $RT  
$rtc | Set-AzRouteTable
}
}

