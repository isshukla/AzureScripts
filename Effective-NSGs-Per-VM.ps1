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

#To find the NSGs associated with a VM's NIC and the Subnet


Write-Host "Output files 'NSG-DIP.txt' and 'All-NSG-VM-DIP.csv' will be created in C:\" -ForegroundColor Green

#Creating the txt file with Column names
"NIC/Subnet-Level:NSG-Name + VM-Name + NIC/Subnet-Name + DIP" | Out-File  c:\nsg-DIP.txt


#Get all Network Interfaces, this will have the Resource Group names, and VM names as well
$r = Get-AzureRmNetworkInterface
$rg = ($r.ResourceGroupName)
$c = ($r.virtualmachinetext)
$c = $c | foreach {$_ -replace ".*/" -replace "}" -replace "{" -replace '"'}
$c = $c.trim()
$VMname = ($C)
#$r.name

#Getting the value of count for which the Loop will run
$count = $r.count


#Creating empty Arrays
$NICname = ($r.name)
$nsgnames = @()
$subnet = @()
$Vnetarray = @()
$nsgSUBNET = @()
$dip1 = @()
$forrg2 = @()



#For loop to Get the NSGs 
#################################

for ($i=0; $i -lt $count; $i++)
{
 
#$i

#To get VM 
$test = $VMname[$i]
#$VM = Get-AzureRmVM -ResourceGroupName $RG[$i] -Name $VMname[$i]

#To get NICs and NSGs for those NICs
#$temp = $vm.NetworkProfile.NetworkInterfaces.id
#$NIC = $temp | ForEach-Object {$_ -replace ".*/" }

#$NICname += ($nic)
$test4 = $NICname[$i]
#$test4

$nic = Get-AzureRmNetworkInterface -Name $NICname[$i] -ResourceGroupName $RG[$i]
$nsg = $nic.NetworkSecurityGroupText
$nsgname = $nsg | ForEach-Object {$_ -replace ".*/" -replace "{","" -replace "}","" -replace '"'}

$nsgname = $nsgname.Trim()
$nsgnames += ($nsgname)

#Finding the Subnets associated with the NICs
$sub = $nic.IpConfigurations.subnettext | ForEach-Object {$_ -replace ".*/" -replace '"Delegations"' -replace '"ServiceAssociationLinks"' -replace '\n','' `
-replace '".*' -replace '.*,'
}
$sub = $sub.Trim()
$subnet += ($Sub)
$test2 = $subnet[$i]

#To get the VNETs
$vnetname = $nic.IpConfigurations.subnettext | ForEach-Object {$_ -replace ".*virtualNetworks/" -replace "subnets.*" `
-replace '"Delegations"' -replace '"ServiceAssociationLinks"' -replace '\n','' -replace "/.*" -replace ".*,"}
$vnetname = $vnetname.trim()
$Vnetarray += ($vnetname)
$test3  = $Vnetarray[$i]

$rg2 = $nic.IpConfigurations.subnettext | ForEach-Object {$_ -replace ".*resourceGroups/" -replace "providers.*" `
-replace '"Delegations"' -replace '"ServiceAssociationLinks"' -replace '\n','' -replace "/.*" -replace ".*,"}
$rg2 = $rg2.Trim()
$forrg2 += ($rg2)

$getvnet = Get-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $rg2  -WarningAction SilentlyContinue
#$getvnet


$getsub = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnet[$i] -VirtualNetwork $getvnet  -WarningAction SilentlyContinue
#$getsub 

#To get the NGS at Subnet level
$nsg2 = $getsub.NetworkSecurityGroupText
#$nsg2

#NSG Name at the Subnet Level
$nsgname2 = $nsg2 | ForEach-Object {$_ -replace ".*/" -replace "{","" -replace "}","" -replace '"'}
$nsgname2 = $nsgname2 -replace '\n',''
$nsgname2 = $nsgname2.Trim()
$nsgSUBNET += ($nsgname2)
#$nsgname2



# To get the Private IP associated with the NICs
$DIP = ($nic).IpConfigurations.PrivateIpAddress
$dip1 += ($dip)

#"NSG-NIC-Level: $nsgname + $test + NIC:$test4 + $dip"
#"NSG-Subnet-Level: $nsgname2 + $test + Subnet:$test2 + $dip"
"NSG-NIC-Level: $nsgname + $test + NIC:$test4 + $dip"  | out-file c:\nsg-dip.txt -Append
"NSG-Subnet-Level: $nsgname2 + $test + Subnet:$test2 + $dip"  | out-file c:\nsg-dip.txt -Append


}

#Importing the vlaues in CSV File
Import-Csv -Path C:\nsg-dip.txt -Delimiter "+" | Export-Csv -Path c:\All-NSG-VM-DIP.csv -NoTypeInformation -Append
