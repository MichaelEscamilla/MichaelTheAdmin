param (
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

# Get Update files
Show-TSActionProgress -Message "Finding Update files in Directory: [$($DownloadPath)]" -Step 1 -MaxStep 2
Write-Host "Finding Update files in Directory: [$($DownloadPath)]"
$UpdateFiles = Get-ChildItem -Path "$($DownloadPath)" | Where-Object { $_.PSIsContainer -eq $false }
Show-TSActionProgress -Message "Successfully Found: [$($UpdateFiles.Count)] Updates" -Step 2 -MaxStep 2

# Install Updates
Show-TSActionProgress -Message "Installing Updates" -Step 1 -MaxStep $($UpdateFiles.Count + 1)
# Set Scratch Directory
$ScratchDir = "$($DownloadPath)\_Update-Scratch"
# Create Directory if it doesn't Exists
if (!(Test-Path -Path $ScratchDir)) {
    New-Item -Path $ScratchDir -ItemType Directory -Force | Out-Null -Verbose
}
# Install Updates
[long]$StepCount = 0
Show-TSActionProgress -Message "Installing Updates" -Step $StepCount -MaxStep $($Updates.Count + 1)
foreach ($Update in $UpdateFiles) {
    $StepCount++
    Write-Host "Installing Update: [$($Update.FullName)]"
    Show-TSActionProgress -Message "Installing Update: [$($Update.Name)]" -Step $StepCount -MaxStep ($UpdateFiles.Count + 1)
    Add-WindowsPackage -Path "C:\" -PackagePath "$($Update.FullName)" -NoRestart -ScratchDirectory "$($ScratchDir)" -Verbose
    Start-Sleep -Seconds 5
}