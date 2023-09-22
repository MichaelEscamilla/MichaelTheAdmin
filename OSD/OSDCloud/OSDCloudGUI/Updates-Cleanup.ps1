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

# Delete Download Path
Show-TSActionProgress -Message "Deleting Download Path: [$($DownloadPath)]" -Step 1 -MaxStep 2
Remove-Item -Path "$($DownloadPath)" -Recurse -Force -Verbose

# Verify Download Path is Deleted
Show-TSActionProgress -Message "Verifying Download Path has been Delted" -Step 2 -MaxStep 3
if (Test-Path -Path "$($DownloadPath)") {
    Show-TSActionProgress -Message "Successfully Deleted Download Path" -Step 3 -MaxStep 3
}