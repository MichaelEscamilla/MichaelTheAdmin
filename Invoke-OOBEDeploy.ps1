#=================================================
#region Start Transcript
$Global:Transcript = "$((Get-Date).ToString('yyyy-Mm-dd-HHmmss'))-Invoke-OOBEDeploy.log"
Start-Transcript -Path (Join-Path "C:\" $Global:Transcript) -ErrorAction Ignore
#endregion
#=================================================

# Import 'OSD' Module
Invoke-Expression (Invoke-RestMethod functions.osdcloud.com)

# Start OOBEDeploy
Start-OOBEDeploy -Verbose

#=================================================
#region End Transcript
Stop-Transcript -ErrorAction Ignore
#endregion
#=================================================

Restart-Computer -Force