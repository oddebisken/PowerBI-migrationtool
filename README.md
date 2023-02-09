# TENANT TO TENANT MIGRATION TOOL FOR POWERBI

## What?
This is a script that helps you to move files from tenant to tenant. 
Supportet migration:
- Workspaces
- Workspace users
- Reports
- Datasets
- Dataset users
- Dashboardnames (content in dashboard is unfortunately impossible to import)

## How to use:
Just run the migration.ps1 file in your favorite powershell tool :)
Halfway through, the script will present every finding in your source environment. 
If this is empty, you might consider to check your permission.

## Prerequisites
Source power bi Admin user
Destination power bi Admin user

## Powershellversion
Tested in Powershell 7.3 and Powershell 5.1

## Scriptversion log
- 0.1 - Basic export tested
- 0.2 - Basic import installed
- 0.3 - Building the json
- 0.4 - Building report in HTML
