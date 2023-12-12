<# https://MichaeltheAdmin.com

Create the file "$($env:SystemDrive)\OSDCloud\Automate\OSDeploy.AutopilotOOBE.json"
and 'OSDCloudGUI' will import the file

Working off the infromation here
https://akosbakos.ch/osdcloud-4-oobe-customization/

#>

# Set OSDCloudGUI Defaults
$Global:AutopilotOOBE = [ordered]@{
    Title           = 'Michael the Admin - Autopilot Registration'
    GroupTag        = 'MTA-USALPT'
    GroupTagOptions = @(
        'MTA-USALPT',
        'MTA-USAWRK',
        'MTA-MEXLPT',
        'MTA-MEXWRK'
    )
    Hidden = 'AddToGroup'
    Assign = $true
}

# Create 'OSDeploy.OOBEDeploy.json' - During WinPE SystemDrive will be 'X:'
$AutopilotOOBEjson = New-Item -Path "$($env:ProgramData)\OSDeploy\OSDeploy.AutopilotOOBE.json" -Force

# Covert data to Json and export to the file created above
$Global:AutopilotOOBE | ConvertTo-Json -Depth 10 | Out-File -FilePath $($AutopilotOOBEjson.FullName) -Force