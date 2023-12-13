<# https://MichaeltheAdmin.com

Create the file "C:\OSDeploy\OSDeploy.AutopilotOOBE.json"
and 'Start-AutopilotOOBE' will import the file

Working off the infromation here
https://autopilotoobe.osdeploy.com/

#>

# Set OSDCloudGUI Defaults
$Global:AutopilotOOBE = [ordered]@{
    Title           = 'Michael the Admin - Autopilot Registration'
    GroupTag        = 'MTA-USALPT'
    GroupTagOptions = @(
        'MTA-USALPT',
        'MTA-USAWRK'
    )
    AssignedComputerNameExample = 'ExampleComputerName'
    Hidden = 'AddToGroup'
    Assign = $true
    PostAction = 'Restart'
    Docs = 'https://michaeltheadmin.com'
}

# Create 'OSDeploy.AutopilotOOBE.json' - This needs to be written to the 'C:' drive
$AutopilotOOBEjson = New-Item -Path "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" -Force

# Covert data to Json and export to the file created above
$Global:AutopilotOOBE | ConvertTo-Json -Depth 10 | Out-File -FilePath $($AutopilotOOBEjson.FullName) -Force