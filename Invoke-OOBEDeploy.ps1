#=================================================
#region Start Transcript
$Global:Transcript = "$((Get-Date).ToString('yyyy-Mm-dd-HHmmss'))-Invoke-OOBEDeploy.log"
Start-Transcript -Path (Join-Path "C:\" $Global:Transcript) -ErrorAction Ignore
#endregion
#=================================================

# Create Script Folder
$scriptFolderPath = "$env:SystemDrive\OSDCloud\Scripts"
$scriptPathSendKeys = $(Join-Path -Path $scriptFolderPath -ChildPath "SendKeys.ps1")
$ScriptPathOOBE = $(Join-Path -Path $scriptFolderPath -ChildPath "OOBE.ps1")

$SendKeysScript = @"
`$Global:Transcript = "`$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-SendKeys.log"
Start-Transcript -Path (Join-Path "`$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" `$Global:Transcript) -ErrorAction Ignore | Out-Null

Write-Host -ForegroundColor DarkGray "Stop Debug-Mode (SHIFT + F10) with WscriptShell.SendKeys"
`$WscriptShell = New-Object -com Wscript.Shell

# ALT + TAB
Write-Host -ForegroundColor DarkGray "SendKeys: ALT + TAB"
`$WscriptShell.SendKeys("%({TAB})")

Start-Sleep -Seconds 1

# Shift + F10
Write-Host -ForegroundColor DarkGray "SendKeys: SHIFT + F10"
`$WscriptShell.SendKeys("+({F10})")

`$WscriptShell.SendKeys("powershell")
Start-Sleep -Seconds 5
`$WscriptShell.SendKeys("Start-OOBEDeploy")

Stop-Transcript -Verbose | Out-File
"@

Out-File -FilePath $ScriptPathSendKeys -InputObject $SendKeysScript -Encoding ascii

<# $OOBEScript =@"
`$Global:Transcript = "`$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OOBEScripts.log"
Start-Transcript -Path (Join-Path "`$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" `$Global:Transcript) -ErrorAction Ignore | Out-Null

Write-Host -ForegroundColor DarkGray "Installing OSD PS Module"
Start-Process PowerShell -ArgumentList "-NoL -C Install-Module OSD -Force -Verbose" -Wait

Write-Host -ForegroundColor DarkGray "Executing OOBEDeploy Script fomr OSDCloud Module"
Start-Process PowerShell -ArgumentList "-NoL -C Start-OOBEDeploy" -Wait

Write-Host -ForegroundColor Green "Pausing...."
Start-Process PowerShell -ArgumentList "-NoL -C Start-Sleep -Seconds 900" -Wait

Stop-Transcript -Verbose | Out-File
"@ #>
$OOBEScript =@"
`$Global:Transcript = "`$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OOBEScripts.log"
Start-Transcript -Path (Join-Path "`$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" `$Global:Transcript) -ErrorAction Ignore | Out-Null

Write-Host -ForegroundColor DarkGray "Installing OSD PS Module"
Install-Module OSD -Force -Verbose

Write-Host -ForegroundColor DarkGray "Executing OOBEDeploy Script fomr OSDCloud Module"
Start-OOBEDeploy

whoami

Write-Host -ForegroundColor Green "Pausing...."
Start-Sleep -Seconds 900

Stop-Transcript -Verbose | Out-File
"@

Out-File -FilePath $ScriptPathOOBE -InputObject $OOBEScript -Encoding ascii

# Download ServiceUI.exe
Write-Host -ForegroundColor Gray "Download ServiceUI.exe from GitHub Repo"
Invoke-WebRequest https://github.com/AkosBakos/Tools/raw/main/ServiceUI64.exe -OutFile "C:\OSDCloud\ServiceUI.exe"

#Create Scheduled Task for SendKeys with 15 seconds delay
$TaskName = "Scheduled Task for SendKeys"

$ShedService = New-Object -comobject 'Schedule.Service'
$ShedService.Connect()

$Task = $ShedService.NewTask(0)
$Task.RegistrationInfo.Description = $taskName
$Task.Settings.Enabled = $true
$Task.Settings.AllowDemandStart = $true

# https://msdn.microsoft.com/en-us/library/windows/desktop/aa383987(v=vs.85).aspx
$trigger = $task.triggers.Create(9) # 0 EventTrigger, 1 TimeTrigger, 2 DailyTrigger, 3 WeeklyTrigger, 4 MonthlyTrigger, 5 MonthlyDOWTrigger, 6 IdleTrigger, 7 RegistrationTrigger, 8 BootTrigger, 9 LogonTrigger
$trigger.Delay = 'PT15S'
$trigger.Enabled = $true

$action = $Task.Actions.Create(0)
$action.Path = 'C:\OSDCloud\ServiceUI.exe'
$action.Arguments = '-process:RuntimeBroker.exe C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe ' + $ScriptPathSendKeys + ' -NoExit'

$taskFolder = $ShedService.GetFolder("\")
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa382577(v=vs.85).aspx
$taskFolder.RegisterTaskDefinition($TaskName, $Task , 6, "SYSTEM", $NULL, 5)


# Create Scheduled Task for OSDCloud post installation with 20 seconds delay
$TaskName = "Scheduled Task for OSDCloud post installation"

$ShedService = New-Object -comobject 'Schedule.Service'
$ShedService.Connect()

$Task = $ShedService.NewTask(0)
$Task.RegistrationInfo.Description = $taskName
$Task.Settings.Enabled = $true
$Task.Settings.AllowDemandStart = $true

# https://msdn.microsoft.com/en-us/library/windows/desktop/aa383987(v=vs.85).aspx
$trigger = $task.triggers.Create(9) # 0 EventTrigger, 1 TimeTrigger, 2 DailyTrigger, 3 WeeklyTrigger, 4 MonthlyTrigger, 5 MonthlyDOWTrigger, 6 IdleTrigger, 7 RegistrationTrigger, 8 BootTrigger, 9 LogonTrigger
$trigger.Delay = 'PT20S'
$trigger.Enabled = $true

$action = $Task.Actions.Create(0)
$action.Path = 'C:\OSDCloud\ServiceUI.exe'
$action.Arguments = '-process:cmd.exe C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe ' + $ScriptPathOOBE + ' -NoExit'

$taskFolder = $ShedService.GetFolder("\")
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa382577(v=vs.85).aspx
#$taskFolder.RegisterTaskDefinition($TaskName, $Task , 6, "SYSTEM", $NULL, 5)


# Import 'OSD' Module
#Invoke-Expression (Invoke-RestMethod functions.osdcloud.com)

# Start OOBEDeploy
#Start-OOBEDeploy -Verbose

#=================================================
#region End Transcript
Stop-Transcript -ErrorAction Ignore
#endregion
#=================================================