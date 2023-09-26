<# https://MichaeltheAdmin.com

Create the file "$($env:SystemDrive)\OSDCloud\Automate\OSDeploy.AutopilotOOBE.json"
and 'OSDCloudGUI' will import the file

Working off the infromation here
https://akosbakos.ch/osdcloud-4-oobe-customization/

#>

# Set OSDCloudGUI Defaults
$Global:AutopilotOOBE = [ordered]@{
    AddNetFX3  = @{
        IsPresent = $true
    }
    RemoveAppx = @(
        "MicrosoftTeams",
        "Microsoft.BingWeather",
        "Microsoft.BingNews",
        "Microsoft.GamingApp",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.Messaging",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.MSPaint",
        "Microsoft.People",
        "Microsoft.PowerAutomateDesktop",
        "Microsoft.StorePurchaseApp",
        "Microsoft.Todos",
        "microsoft.windowscommunicationsapps",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo"
    )
}

# Create 'OSDeploy.OOBEDeploy.json' - During WinPE SystemDrive will be 'X:'
$AutopilotOOBEjson = New-Item -Path "$($env:SystemDrive)\OSDCloud\Config\OOBEDeploy\OSDeploy.OOBEDeploy.json" -Force

# Covert data to Json and export to the file created above
$Global:AutopilotOOBE | ConvertTo-Json -Depth 10 | Out-File -FilePath $($AutopilotOOBEjson.FullName) -Force