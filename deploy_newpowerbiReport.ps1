<#
.Synopsis
    Migrates all reports and datasets from Tenant to Tenant

.Description
    Re-creates all workspaces and moves respective .PBIX files from one Tenant to the other. 
    It will also bring all "Accessed users". 


# Made by Odd Daniel Taasaasen 
# 02.02.2023
# Versjon 0.1

#>
# ==============================================================================

#To start the script, simply press F5 in your favorite PowerShell editor

# Command line Parameters ======================================================
cd C:\GIT\ObosFellesAD.PowerBiMigration\

try {import-module MicrosoftPowerBIMgmt}
catch {install-module MicrosoftPowerBIMgmt -Force -AllowClobber}
$root = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\')
try {New-Item -Path $root -Name "pbixfiles" -ItemType "directory"}catch{write-host "Directory already exists"}
try {New-Item -Path $root -Name "logfiles" -ItemType "directory"}catch{write-host "Directory already exists"}
$pbixpath = "$root/pbixfiles"
$logpath = "$root/logfiles"
set-location $root

# ==============================================================================
<#
#APPREG info ================= 
$boxtype = "MultiExtended" #dialog box type
. $root\Data\Dialogbox_info.ps1
$TenantID_Source, $clientid_Source, $clientsecret_Source, $TenantID_Destination, $clientid_Destination, $clientsecret_Destination, $result = Dialogbox_info -root $root


#log in to Source using PSCredential object
$SecuredPassword_Source= ConvertTo-SecureString $clientsecret_Source -AsPlainText -Force
$Credential_Source = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientid_Source, $SecuredPassword_Source
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $Credential_Source -Tenant $TenantID_Source

# ==============================================================================
$Shell = New-Object -ComObject "WScript.Shell"
$Button = $Shell.Popup("You have provided with the following information: `
`
Source: `
TenantID: $TenantID_Source `
ClientID: $clientid_Source `
ClientSecret: [TOP SECRET] `
`
Destination: `
TenantID: $TenantID_Destination `
ClientID: $clientid_Destination `
ClientSecret: [TOP SECRET]",0, "Migrationtool", 1)

if($button -like 2) {
  break
}
#>

Connect-PowerBIServiceAccount
start-sleep -Seconds 3
#Build the report:
$html = @()
$html += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Power BI Migrationtool</title>
<link rel="stylesheet" type="text/css" href="./styles.css"/>
</head>'

$html += '<h1>Power BI Migration Tool Report</h1>'
$html += '<p>Created by Odd Daniel Taasaasen @ Point Taken</p> '
$html += '<h2>All reports from Source('+$TenantID_Source+'):</h2>'


#List all workspaces
$listworkspace = Get-PowerBIWorkspace -Scope Organization -all | Where-Object -Property Type -eq "Workspace"
#$listworkspace | Export-Csv -Path "$logpath/allsourceworkspaces.csv" -Force

$title = "Select the workspaces you want to migrate:" #text on top of value area
$footer = "Press CTRL or SHIFT to select multiple subscriptions!" #text below the value area
$boxtype = "MultiExtended" #dialog box type
. $root\Data\dialogbox.ps1
$selectedItems, $result = Dialogbox -root $root -listworkspace $listworkspace -footer $footer  -title $title -boxtype $boxtype

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    write-host "`nYou have chosen the following workspaces`n" -ForegroundColor Yellow 
    $selectedItems | % -process {write-host $_ -ForegroundColor Yellow} 
    $selectedworkspaces = $selectedItems
}

if ($result -eq [System.Windows.Forms.DialogResult]::Cancel)
{
    break
}

$json = @()

foreach ($workspace in $selectedworkspaces) {
  #Get all datasets in workspace
  $workspaceid = $workspace.split('|')[1].trim()
  $workspacename = $workspace.split('|')[0].trim()
  $listreports = Get-PowerBIReport -WorkspaceId $workspaceid
  $listdashboards = Get-PowerBIDashboard -WorkspaceId $workspaceid
  $info = "" | Select Workspace, Report, Dataset, Dashboard

  
  #build the table header
  $html += "<br>"
  $html += "<h3>$workspacename</h3>"
  $html += '
    <table>
      <tr>
        <th>Type</th>
        <th>Dataset</th>
        <th>Users</th>
      </tr>
    '
        #set the url based on current workspace + dataset we are in
        $urlbase = "groups/$workspaceid/"
        $method = "GET" 
        $format = "$"+"format"
        $url = $urlbase + "users?$format=application/json;odata.metadata=none"
        $result = Invoke-PowerBIRestMethod -Url $url -Method $method 
        $result = $result | ConvertFrom-Json
  
        #get the access list from each dataset
        $workspaceusers = $result.value.identifier | Where-Object {$_.contains("@")}
        $userstring = ""
        foreach ($user in $workspaceusers) {
          $userstring += $user+", "
        }
        $access = $result.value | Where-Object {$_.identifier.contains("@")}
  
        $Workspace = [PSCustomObject]@{
          WorkspaceName = $workspacename
          WorkspaceID = $workspaceid
          WorkspaceUsers = $workspaceusers
        }
        $info.Workspace = $Workspace
        $info.Dashboard = $listdashboards
        $json = $info
        #add the important stuff to the html table for review
        $html += '
          <tr>
            <td>Workspace</td>
            <td>'+$workspacename+'</td>
            <td>'+$userstring+'</td>
          </tr>
        '

    foreach ($report in $listreports) {
      #get variables from dataset
      $reportname = $report.Name
      $reportid = $report.Id
      $datasetid = $report.DatasetId

      #set the filename of report
      $file = $pbixpath+"/"+$reportname+".pbix"
      Export-PowerBIReport -Id $reportid -OutFile $file
      

      #set the url based on current workspace + dataset we are in
      $urlbase = "groups/$workspaceid/datasets/$datasetid/"
      $method = "GET" 
      $format = "$"+"format"
      $url = $urlbase + "users?$format=application/json;odata.metadata=none"
      $result = Invoke-PowerBIRestMethod -Url $url -Method $method 
      $result = $result | ConvertFrom-Json

      #get the access list from each dataset
      $datasetusers = $result.value.identifier | Where-Object {$_.contains("@")}
      $userstring = ""
      foreach ($user in $datasetusers) {
        $userstring += $user+", "
      }
      $access = $result.value | Where-Object {$_.identifier.contains("@")}

      #add the important stuff to the html table for review
      $html += '
        <tr>
          <td>Dataset</td>
          <td>'+$reportname+'</td>
          <td>'+$userstring+'</td>
        </tr>
      '

      #build the json file for this workspace

      $Report = [PSCustomObject]@{
        ReportName = $reportname
        ReportId = $reportid
      }
      $Dataset = [PSCustomObject]@{
        DatasetName = $reportname
        Datasetid = $datasetid
        DatasetUsers = $datasetusers
      }
      $infomore = "" | Select Report, Dataset
      $infomore.Report = $Report
      $infomore.Dataset = $Dataset
      $json += $infomore
    }
    foreach ($dashboard in $listdashboards) {
      $dashboardname = $dashboard.Name
      $dashboardid = $dashboard.Id

      #add the important stuff to the html table for review
      $html += '
      <tr>
        <td>Dashboard</td>
        <td>'+$dashboardname+'</td>
        <td></td>
      </tr>
    '
    }
  
  $jsonfile = $file = $pbixpath+"/"+$workspaceid+".json"
  $json | convertto-json -depth 100 | Out-File -FilePath $jsonfile -Force
  $html += "</table>"
}

$html | Out-File -FilePath "$root/htmlreport.html" -force
Invoke-Item $root/htmlreport.html
Disconnect-PowerBIServiceAccount

$Shell = New-Object -ComObject "WScript.Shell"
$Button = $Shell.Popup("Please read through the report, and press OK`
You will now be prompted to log in to your Destination Admin",0, "Migrationtool", 1)

if($button -like 2) {
  break
}

<#
$alljson = Get-ChildItem -path $pbixpath | where-object {$_.Name.EndsWith('.json')}
$allpbix = Get-ChildItem -path $pbixpath | where-object {$_.Name.EndsWith('.pbix')}

foreach ($jsonfile in $alljson) {
  $workspacename = $jsonfile.Name.Trim('.json')
  $newworkspace = New-PowerBIWorkspace -Name $workspacename
  $newworkspaceid = $newworkspace.Id
  $jsonpayload = Get-Content -Path $jsonfile.FullName | ConvertFrom-Json
  foreach ($report in $jsonpayload) {
    if ($report.Dashboardname) {
      New-PowerBIDashboard -Name $report.Dashboardname -WorkspaceId $newworkspaceid
    }else {write-host "something ELSE"}
    $pbixfile = $allpbix | Where-Object {$_.BaseName -eq $report.Name}
    $newreport = New-PowerBIReport -Path $pbixPath -Name $reportName -WorkspaceId $newworkspaceid -ConflictAction CreateOrOverwrite -Verbose
    
    $newinfo = "" | Select Workspace, Report, Dashboard
    $Workspace = [PSCustomObject]@{
      Workspacename = $workspacename
      WorkspaceID = $newworkspaceid
      WorkspaceUsers = $
    }
    
    $newreportinfo.Reportname = $report.Name
    $newreportinfo.ReportId = $newreport.Id
    $newreportinfo.DatasetID = $newreport.DatasetId
    $newjson = @()


    


  }
}




###################### OL 



#List all accessess
$urlbase = "groups/$groupid/datasets/$datasetid/"




#################### HOSTILE TAKE OVER the dataset #################
    $url = $urlbase + "Default.TakeOver"
    Invoke-PowerBIRestMethod -Url $url -Method Post 
    Write-Host "#################### HOSTILE TAKE OVER the dataset SUCCESS #################"
GET https://api.powerbi.com/v1.0/myorg/groups/{groupId}/datasets/{datasetId}

disconnect-powerbiserviceaccount






#log in to Destination using PSCredential object
$SecuredPassword_Destination= ConvertTo-SecureString $clientsecret_Destination -AsPlainText -Force
$Credential_Destination = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientid_Destination, $SecuredPassword_Destination
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $Credential_Destination -Tenant $TenantID_Destination




Add-PowerBIWorkspaceUser -Scope Organization -Id 23FCBDBD-A979-45D8-B1C8-6D21E0F4BE50 -UserEmailAddress john@contoso.com -AccessRight Admin


#get report file name from the full path
$pbixPath = "$rootpath"
$reports = Get-ChildItem  $pbixPath

foreach ($report in $reports) {

}

$reportFileToPublish = $report.name

#get or set variables
$workspaceNameProd = "Azure"
$workspaceNameDev = "Azure - DEV"
$datasetRefresh = "Yes"
$Customername = $Customername.ToLower()
$reportName = $Customername

Write-Host "`nReport file to publish: "$reportFileToPublish
write-host "################################################### TENANT ID = $TenantID#############################################"


#get workspace by workspace name
if ($environment -eq "dev") {
  $workspaceObject = Get-PowerBIWorkspace -Name $workspaceNameDev
} else { 
  $workspaceObject = Get-PowerBIWorkspace -Name $workspaceNameProd
}

#get #workspace id 
$groupid = $workspaceObject.id

#publish a copy of the report (overwrite existing)
$result = New-PowerBIReport -Path $pbixPath -Name $reportName -Workspace $workspaceObject -ConflictAction CreateOrOverwrite -Verbose
#get report id
$reportid = $result.id

Write-Host "============================================================================`n"
Write-Host -NoNewline "Report: "$reportName" (published)`n`nReport id: "$reportid
Write-Host "`n`nWorkspace id: "$groupid

#get dataset 
$dataset = Get-PowerBIDataset -Workspace $workspaceObject | Where-Object {$_.Name -eq $reportName}
#get datasetid
$datasetid = $dataset.id

Write-Host "`nDatasetid: "$dataset.id
#Create URL Base for all future API calls

$urlbase = "groups/$groupid/datasets/$datasetid/"

#################### HOSTILE TAKE OVER the dataset #################
    $url = $urlbase + "Default.TakeOver"
    Invoke-PowerBIRestMethod -Url $url -Method Post 
    Write-Host "#################### HOSTILE TAKE OVER the dataset SUCCESS #################"

#################### UPDATE THE PARAMETERS #########################
if ($parameter1Name) { 
    Write-Host "Initiating update of parameters"
    #url and body for UpdateParameters API call
    $url = $urlbase + "default.UpdateParameters"
  
$body = @"
  {
    "updateDetails": [
      {
        "name": "$parameter1Name",
        "newValue": "$parameter1Value"
      },
      {
        "name": "$parameter2Name",
        "newValue": "$parameter2Value"
      },
      {
        "name": "$parameter3Name",
        "newValue": "$parameter3Value"
      },
      {
        "name": "$parameter4Name",
        "newValue": "$parameter4Value"
      },
      {
        "name": "$parameter5Name",
        "newValue": "$parameter5Value"
      }
    ]
  }
"@
  

    #update parameter's value
    write-host "URL : " $url
    write-host "BODY : " $body
    Invoke-PowerBIRestMethod -Url $url -Method Post -Body $body -verbose
    
    Write-Host "`n -> parameter '"$parameter1Name"' updated. New value: "$parameter1Value
    Write-Host "`n -> parameter '"$parameter2Name"' updated. New value: "$parameter2Value
    Write-Host "`n -> parameter '"$parameter3Name"' updated. New value: "$parameter3Value
    Write-Host "`n -> parameter '"$parameter4Name"' updated. New value: "$parameter4Value
    Write-Host "`n -> parameter '"$parameter5Name"' updated. New value: "$parameter5Value
    Write-Host "#################### Update parameters SUCCESS #################"
}
else {
    Write-Host "`nNo parameters to update"
}

#################### DATASET REFRESH #########################
#url and body for refresh schedule API call
  Write-host "initiating refreshSchedule"
  $url=$urlbase + "refreshSchedule"
  $body = @"

{
  "value": {
    "notifyOption": "NoNotification",
    "enabled":"true",
    "times":[
    "04:00","06:00","09:00","11:00","13:00","15:00","18:00","20:00"
  ],
  "days":[
    "Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"
  ],
  "localTimeZoneId":"Romance Standard Time"
  }
}

"@


# Settings up refresh schedule
Invoke-PowerBIRestMethod -Url $url -Method Patch -Body $body -verbose
Invoke-PowerBIRestMethod -Url $url -Method GET -verbose


Write-Host "#################### Update refreshSchedule SUCCESS #################"

#################### REFRESH NOW GAD DAMNIT #########################
  $url=$urlbase + "refreshes"
  $body = @"
{
    "notifyOption": "NoNotification",
}

"@
  
# Refresh the dataset
try{
Invoke-PowerBIRestMethod -Url $url -Method Post -Body $body -verbose -ErrorAction Stop
}
catch {
  Write-Host "Not able to do refresh now, most probably a refresh is already ongoing"
}
Write-Host " -> dataset refreshed"

#Log out of the Power BI service
Disconnect-PowerBIServiceAccount

Write-Host "`nGon' to sleeeeeeeeeeeeeeeeeeeep"

# ==============================================================================


#>