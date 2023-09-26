<# https://MichaeltheAdmin.com

Create the file "$($env:SystemDrive)\OSDCloud\Automate\OSDeploy.AutopilotOOBE.json"
and 'OSDCloudGUI' will import the file

Working off the infromation here
https://akosbakos.ch/osdcloud-4-oobe-customization/

#>

# Set OSDCloudGUI Defaults
$Global:OOBEDeploy = [ordered]@{
    AddNetFX3  = @{
        IsPresent = $true
    }
    AddRSAT = @{
        IsPresent = $false
    }
    Autopilot = @{
        IsPresent = $false
    }
    UpdateDrivers = @{
        IsPresent = $false
    }
    UpdateWindows = @{
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
$OOBEDeployjson = New-Item -Path "$($env:SystemDrive)\OSDCloud\Config\OOBEDeploy\OSDeploy.OOBEDeploy.json" -Force

# Covert data to Json and export to the file created above
$Global:OOBEDeploy | ConvertTo-Json -Depth 10 | Out-File -FilePath $($OOBEDeployjson.FullName) -Force