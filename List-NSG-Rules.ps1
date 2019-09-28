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

# To list the Rules of NSG

$rg = Read-Host "RG Name"
$nsgname = Read-Host "NSG Name"

$nsg2 = Get-AzNetworkSecurityGroup -ResourceGroupName $rg -Name $nsgname
$rule2 = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg2
$rule2 | FT -Property Name, Protocol ,SourcePortRange, DestinationPortRange, SourceAddressPrefix, DestinationAddressPrefix, Access , Priority , Direction 

$FN = $nsg2.Name

$path = $env:TEMP+$FN+'.txt'
$path2 = $env:TEMP+$FN+'.csv'

Write-Host "Output files '$FN'.csv'' and '$FN'.txt'' will be created in $($env:TEMP)" -ForegroundColor Green

"Name + Protocol + SourcePortRange + SourceAddressPrefix + DestinationPortRange + DestinationAddressPrefix + Access + Priority + Direction" | Out-File $path

#$rule2 | FT -Property Name, Protocol ,SourcePortRange, DestinationPortRange

$Access = @()
$Access += $($rule2.Access)

$Priority = @()
$Priority += $($rule2.Priority)

$Direction = @()
$Direction += $($rule2.Direction)

$Protocol = @()
$Name = @()

$Protocol += $($rule2.Protocol) 
$Name += $($rule2.Name)

$SourcePortRange = @()
$SourcePortRange += $($rule2.SourcePortRange)

$SourceAddressPrefix =@()
$SourceAddressPrefix += $($rule2.SourceAddressPrefix)

$DestinationPortRange = @()
$DestinationPortRange += $($rule2.DestinationPortRange)

$DestinationAddressPrefix =@()
$DestinationAddressPrefix += $($rule2.DestinationAddressPrefix)



for ($i=0; $i -lt $rule2.Count; $i++){

$ProtocolF = $Protocol[$i]
$Namef = $Name[$i]
$SourcePortRangef =	$SourcePortRange[$i]
$SourceAddressPrefixf =	$SourceAddressPrefix[$i]
$DestinationPortRangef =	$DestinationPortRange[$i]
$DestinationAddressPrefixf =	$DestinationAddressPrefix[$i]
$Accessf =	$Access[$i]
$Priorityf =	$Priority[$i]
$Directionf=	$Direction[$i]


"$namef + $Protocolf + $SourcePortRangef + $SourceAddressPrefixf + $DestinationPortRangef + $DestinationAddressPrefixf + $Accessf + $Priorityf + $Directionf" | Out-File $path -Append
}

Import-Csv -Path $path -Delimiter "+" | Export-Csv -Path $Path2 -NoTypeInformation -Append
Import-Csv $path2 | FT
