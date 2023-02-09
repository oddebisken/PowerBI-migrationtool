function resourcegroups {
    param (
    $location,
    $customername,
    $environment,
    $SpecialResourceGroupName,
    $SpecialResourceGroupEnv,
    $DevSubs,
    $TestSubs,
    $ProdSubs,
    $MainSubscriptionID,
    $log
 )

# Variables
$Customername = $Customername.ToLower()
if(!$environment){}
else{$environment = $environment.ToLower()}
if (!$SpecialResourceGroupName) {
$ResourceGroupProd = "rg-azurekontroll-prod-$location-01"  
$ResourceGroupTest = "rg-azurekontroll-test-$location-01"  
$ResourceGroupDev = "rg-azurekontroll-dev-$location-01"  
}
else {
$ResourceGroupProd = $SpecialResourceGroupName.Replace('environment','prod')
$ResourceGroupTest = $SpecialResourceGroupName.Replace('environment','test')  
$ResourceGroupDev = $SpecialResourceGroupName.Replace('environment','dev')  
}
if (!$SpecialResourceGroupEnv) {
$mainResourceGroup = $ResourceGroupProd
}
else {
if ($SpecialResourceGroupEnv -eq "dev") {
  $mainResourceGroup = $ResourceGroupDev
}
elseif ($SpecialResourceGroupEnv -eq "test") {
  $mainResourceGroup = $ResourceGroupTest
}
elseif ($SpecialResourceGroupEnv -eq "prod") {
  $mainResourceGroup = $ResourceGroupProd
}
else {write-host "I took a pill in Ibiza"}
}

$DevArray = $DevSubs
$TestArray = $TestSubs
$ProdArray = $ProdSubs

#################### Subscriptions in DEV: $devArray ###################
if ($DevSubs){
  foreach ($devS in $DevArray){
    Set-AzContext -SubscriptionId $DevS -WarningAction SilentlyContinue
    try {
      $rgdev = Get-AzResourceGroup -Name $ResourceGroupDev -ErrorAction Stop 
      if($rgdev) {write-host "found prod resource group " $rgdev.ResourceGroupName -ForegroundColor Green}      
    }  
    catch {$error | Out-File -FilePath $log -Append -Force}
    if (!$rgdev) {$rgdev = New-AzResourceGroup -Name $ResourceGroupDev -Location $Location 
    Write-Host "Resourcegroup created: " $rgdev.ResourceGroupName -ForegroundColor Green}
  }
}
else {write-host "no dev subs"}
#################### Subscriptions in TEST: $TestArray ###################
if ($TestSubs) {
  foreach ($TestS in $TestArray){
    Set-AzContext -SubscriptionId $TestS -WarningAction SilentlyContinue
    try {
      $rgtest = Get-AzResourceGroup -Name $ResourceGroupTest -ErrorAction Stop
      if($rgtest) {write-host "found prod resource group " $rgtest.ResourceGroupName -ForegroundColor Green}      
    }  
    catch {$error | Out-File -FilePath $log -Append -Force}
    if (!$rgtest) {$rgtest = New-AzResourceGroup -Name $ResourceGroupTest -Location $Location
    Write-Host "Resourcegroup created: " $rgtest.ResourceGroupName -ForegroundColor Green}
  }
}
else {write-host "no test subs"}

#################### Subscriptions in PROD: $ProdArray  ###################
if ($ProdSubs) {
  foreach ($ProdS in $ProdArray){
    Set-AzContext -SubscriptionId $ProdS -WarningAction SilentlyContinue
    try {
        $rgprod = Get-AzResourceGroup -Name $ResourceGroupProd -ErrorAction Stop
        if($rgprod) {write-host "found prod resource group " $rgprod.ResourceGroupName -ForegroundColor Green}      
    }  
    catch {$error | Out-File -FilePath $log -Append -Force}
    if (!$rgprod) {$rgprod = New-AzResourceGroup -Name $ResourceGroupProd -Location $Location
    Write-Host "Resourcegroup created: " $rgprod.ResourceGroupName -ForegroundColor Green}

  }  
}
else {write-host "no prod subs"}

#Set log analytics name
$WorkspaceName = "log-azurekontroll-$environment-$location-01"
#creating log analytics workspace
set-azcontext -SubscriptionId $MainSubscriptionID
try {
  $la = Get-AzOperationalInsightsWorkspace | Where-Object {$_.Name.StartsWith("log-azurekontroll-")} -ErrorAction stop
  Write-Host "Workspace already created:" $la.Name
} catch {$error | Out-File -FilePath $log -Append -Force}
if(!$la) {
write-host "workspace not existing. Creating now"
$la = New-AzOperationalInsightsWorkspace -Location $Location -Name $WorkspaceName -ResourceGroupName $mainResourceGroup -ErrorAction stop
write-host "successfully created Workspace: "$la.name
}else{}
# Create service account

$loganalyticsID = $la.ResourceId
$WorkspaceName = $la.Name
#$mainResourceGroup = $mainResourceGroup.Trim('Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext')

$rginfo = @()
$rginfo += $mainResourceGroup
$rginfo += $loganalyticsID
$rginfo += $WorkspaceName
return $rginfo


}
