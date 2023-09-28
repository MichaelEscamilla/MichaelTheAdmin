<# https://MichaeltheAdmin.com

Create the file "$($env:SystemDrive)\OSDCloud\Automate\OSDeploy.AutopilotOOBE.json"
and 'OSDCloudGUI' will import the file

Working off the infromation here
https://akosbakos.ch/osdcloud-4-oobe-customization/

#>

# Set OSDCloudGUI Defaults
$Global:AutopilotOOBE = [ordered]@{
    Assign={
        IsPresent = $true
    }
    AssignedUserExample = "Username@example.com"
    AssignedComputerNameExample = "COMPUTERNAME"
    GroupTag = "Tag1"
    GroupTagOptions=@(
        "Tag1",
        "Tag2",
        "Tag3"
    )
    Disabled                    = @(
    )
    Hidden                      = @(
        "Docs",
        "AddToGroup"
    )
    PostAction                  = "Quit"
    Run                         = "MDMDiagAutopilot"
    Title                       = "Autopilot Registration"
}
  

# Create 'OSDeploy.OOBEDeploy.json' - During WinPE SystemDrive will be 'X:'
$AutopilotOOBEjson = New-Item -Path "$($env:SystemDrive)\OSDCloud\Config\AutopilotOOBE\OSDeploy.AutopilotOOBE.json" -Force

# Covert data to Json and export to the file created above
$Global:AutopilotOOBE | ConvertTo-Json -Depth 10 | Out-File -FilePath $($AutopilotOOBEjson.FullName) -Force