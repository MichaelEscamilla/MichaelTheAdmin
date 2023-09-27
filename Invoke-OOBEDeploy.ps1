#=================================================
#region Start Transcript
$Global:Transcript = "$((Get-Date).ToString('yyyy-Mm-dd-HHmmss'))-Invoke-OOBEDeploy.log"
Start-Transcript -Path (Join-Path "C:\" $Global:Transcript) -ErrorAction Ignore
#endregion
#=================================================

# Create Script Folder
$scriptFolderPath = "$env:SystemDrive\OSDCloud\Scripts"
$scriptPathSendKeys = $(Join-Path -Path $scriptFolderPath -ChildPath "SendKeys.ps1")

#=========Create Send Keys Script=================
$SendKeysScript = @"
`$Global:Transcript = "`$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-SendKeys.log"
Start-Transcript -Path (Join-Path "`$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" `$Global:Transcript) -ErrorAction Ignore | Out-Null

`$WscriptShell = New-Object -com Wscript.Shell

# Shift + F10
Write-Host -ForegroundColor DarkGray "SendKeys: SHIFT + F10"
`$WscriptShell.SendKeys("+({F10})")

Start-Sleep -Seconds 1

# ALT + TAB
Write-Host -ForegroundColor DarkGray "SendKeys: ALT + TAB"
`$WscriptShell.SendKeys("^%({TAB}{TAB}{TAB})")
Start-Sleep -Seconds 5
`$WscriptShell.SendKeys("{ENTER}")
Start-Sleep -Seconds 5

# Start Powershell
`$WscriptShell.SendKeys("powershell{ENTER}")

Start-Sleep -Seconds 5

# Start OOBEDeploy
`$WscriptShell.SendKeys("Start-OOBEDeploy{ENTER}")

Stop-Transcript -Verbose | Out-File
"@

Out-File -FilePath $ScriptPathSendKeys -InputObject $SendKeysScript -Encoding ascii
#=================================================

# Download ServiceUI.exe
Write-Host -ForegroundColor Gray "Download ServiceUI.exe from GitHub Repo"
Invoke-WebRequest https://github.com/MichaelEscamilla/MichaelTheAdmin/raw/main/Tools/ServiceUI64.exe -OutFile "C:\OSDCloud\ServiceUI.exe"

#Create Scheduled Task for SendKeys with 15 seconds delay
$TaskName = "Scheduled Task for SendKeys"
$TaskName = "_Start-OOBEDeploy"

# Set User Principle to Run Task Schedule
$Username = "NT AUTHORITY\SYSTEM"
$Principal = New-ScheduledTaskPrincipal -UserID $Username -LogonType ServiceAccount -RunLevel Highest

# Create Trigger Time for Task Schedule
$TriggerTime = New-ScheduledTaskTrigger -AtLogOn
$TriggerTime.Delay = "PT15S"

# Create Action for Task Schedule
$Execute = "ServiceUI.exe"
$Arguments = "-process:RuntimeBroker.exe C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe $($ScriptPathSendKeys) -NoExit"
$WorkingDirectory = "C:\OSDCloud"
$TSAction = New-ScheduledTaskAction -Execute $Execute -Argument "$Arguments" -WorkingDirectory $WorkingDirectory

# Register Task
Register-ScheduledTask -TaskName $TaskName -Trigger $TriggerTime -Action $TSAction -Principal $Principal

#=================================================
#region End Transcript
Stop-Transcript -ErrorAction Ignore
#endregion
#=================================================