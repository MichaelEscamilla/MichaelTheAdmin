param (
    [string]$OSName,
    [string]$OSBuildName,
    [string]$DownloadPath
)

<#
    Took these Functions from @gwblock
    https://garytown.com/osdcloud-configmgr-integrated-win11-osd
#>
# Creates a TSProgressUI Variable for the script
function Confirm-TSProgressUISetup() {
    if ($null -eq $Script:TaskSequenceProgressUi) {
        try {
            $Script:TaskSequenceProgressUi = New-Object -ComObject Microsoft.SMS.TSProgressUI 
        }
        catch {
            throw "Unable to connect to the Task Sequence Progress UI! Please verify you are in a running Task Sequence Environment. Please note: TSProgressUI cannot be loaded during a prestart command.`n`nErrorDetails:`n$_"
        }
    }
}
# Gets the Task Sequence Environment information
function Confirm-TSEnvironmentSetup() {
    if ($null -eq $Script:TaskSequenceEnvironment) {
        try {
            $Script:TaskSequenceEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment 
        }
        catch {
            throw "Unable to connect to the Task Sequence Environment! Please verify you are in a running Task Sequence Environment.`n`nErrorDetails:`n$_"
        }
    }
}
# Update the TSProgressUI
function Show-TSActionProgress() {

    param(
        [Parameter(Mandatory = $true)]
        [string] $Message,
        [Parameter(Mandatory = $true)]
        [long] $Step,
        [Parameter(Mandatory = $true)]
        [long] $MaxStep
    )
    # Create TsProgressUI Script:Variable
    Confirm-TSProgressUISetup
    # Gets TS Environment Info
    Confirm-TSEnvironmentSetup

    # Update the Progress UI
    $Script:TaskSequenceProgressUi.ShowActionProgress(`
            $Script:TaskSequenceEnvironment.Value("_SMSTSOrgName"), `
            $Script:TaskSequenceEnvironment.Value("_SMSTSPackageName"), `
            $Script:TaskSequenceEnvironment.Value("_SMSTSCustomProgressDialogMessage"), `
            $Script:TaskSequenceEnvironment.Value("_SMSTSCurrentActionName"), `
            [Convert]::ToUInt32($Script:TaskSequenceEnvironment.Value("_SMSTSNextInstructionPointer")), `
            [Convert]::ToUInt32($Script:TaskSequenceEnvironment.Value("_SMSTSInstructionTableSize")), `
            $Message, `
            $Step, `
            $MaxStep)
}

# Import Module
Show-TSActionProgress -Message "Importing 'OSD' PSModule" -Step 1 -MaxStep 2
Import-Module OSD -Force

# Get Updates Information
Show-TSActionProgress -Message "Finding Updates for: [$($OSName) $($OSBuildName)]" -Step 1 -MaxStep 2
$Updates = Get-WSUSXML -Catalog "$($OSName)" -UpdateBuild "$($OSBuildName)" -UpdateArch x64 | Where-Object { $_.UpdateGroup -eq 'LCU' -or $_.UpdateGroup -eq 'Optional' }
Start-Sleep -Seconds 5
Show-TSActionProgress -Message "Updates Found: [ $($Updates.Count) ]" -Step 2 -MaxStep 2
Start-Sleep -Seconds 5

# Download Updates
[long]$StepCount = 0
Show-TSActionProgress -Message "Downloading Updates" -Step $StepCount -MaxStep $($Updates.Count + 1)
foreach ($Update in $Updates) {
    $StepCount++
    Show-TSActionProgress -Message "Downloading Update: [$($Update.Title)]" -Step $StepCount -MaxStep ($Updates.Count + 1)
    Save-WebFile -SourceUrl $Update.FileUri -DestinationDirectory "$($DownloadPath)" -DestinationName $Update.FileName -Verbose
    Start-Sleep -Seconds 5
}