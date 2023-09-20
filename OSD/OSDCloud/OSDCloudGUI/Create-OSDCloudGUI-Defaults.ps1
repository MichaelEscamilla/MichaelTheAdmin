<# https://MichaeltheAdmin.com

OSDCloudGUI can now be configured with Defaults and Selectable Options in the dropdowns.

Create the file "$($env:SystemDrive)\OSDCloud\Automate\Start-OSDCloudGUI.json"
and the 'Start-OSDCloudGUI' will import the file

https://www.osdcloud.com/osdcloud-automate/osdcloudgui-defaults

#>

# Set OSDCloudGUI Defaults
$Global:OSDCloud_Defaults = [ordered]@{
    BrandName            = "Michael The Admin"
    BrandColor           = "Orange"
    OSActivation         = "Volume"
    OSEdition            = "Enterprise"
    OSLanguage           = "en-us"
    OSImageIndex         = 6
    OSName               = "Windows 11 22H2 x64"
    OSReleaseID          = "22H2"
    OSVersion            = "Windows 11"
    OSActivationValues   = @(
        "Volume",
        "Retail"
    )
    OSEditionValues      = @(
        "Enterprise",
        "Pro"
    )
    OSLanguageValues     = @(
        "el-gr",
        "en-gb",
        "en-us",
        "es-es",
        "es-mx"
    )
    OSNameValues         = @(
        "Windows 11 22H2 x64",
        "Windows 10 22H2 x64"
    )
    OSReleaseIDValues    = @(
        "22H2"
    )
    OSVersionValues      = @(
        "Windows 11",
        "Windows 10"
    )
    captureScreenshots   = $false
    ClearDiskConfirm     = $false
    restartComputer      = $true
    updateDiskDrivers    = $true
    updateFirmware       = $false
    updateNetworkDrivers = $true
    updateSCSIDrivers    = $true
}

# Create 'Start-OSDCloudGUI.json' - During WinPE SystemDrive will be 'X:'
$OSDCloudGUIjson = New-Item -Path "$($env:SystemDrive)\OSDCloud\Automate\Start-OSDCloudGUI.json" -Force

# Covert data to Json and export to the file created above
$Global:OSDCloud_Defaults | ConvertTo-Json -Depth 10 | Out-File -FilePath $($OSDCloudGUIjson.FullName) -Force