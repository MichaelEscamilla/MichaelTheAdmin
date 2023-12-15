#======================================================================================
#   Logs
#======================================================================================
$TaskLogs = "$env:SystemRoot\Logs\Activation"
if (!(Test-Path $TaskLogs)) { New-Item $TaskLogs -ItemType Directory -Force | Out-Null }
$TaskLogName = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-GVLK.log"
Start-Transcript -Path (Join-Path $TaskLogs $TaskLogName)
#======================================================================================
#   Operating System
#======================================================================================
$OSCaption = $((Get-WmiObject -Class Win32_OperatingSystem).Caption).Trim()
$OSProductType = $((Get-WmiObject -Class Win32_OperatingSystem).ProductType)
$OSArchitecture = $((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture).Trim()
$OSVersion = $((Get-WmiObject -Class Win32_OperatingSystem).Version).Trim()
$OSBuildNumber = $((Get-WmiObject -Class Win32_OperatingSystem).BuildNumber).Trim()

#======================================================================================
#   Variables
#======================================================================================
Write-Host "OSCaption: $OSCaption" -ForegroundColor Cyan
Write-Host "OSProductType: $OSProductType" -ForegroundColor Cyan
Write-Host "OSArchitecture: $OSArchitecture" -ForegroundColor Cyan
Write-Host "OSVersion: $OSVersion" -ForegroundColor Cyan
Write-Host "OSBuildNumber: $OSBuildNumber" -ForegroundColor Cyan
#======================================================================================
#   GVLK
#======================================================================================
# Server
if (($OSProductType -eq 2) -or ($OSProductType -eq 3) ) {
    if ($OSCaption -match 'Standard') {
        switch ($OSBuildNumber) {
            # Windows Server 2022 Standard
            20348 { $GVLKey = 'VDYBN-27WPP-V4HQT-9VMD4-VMK7H' }
            #Windows Server 2019 Standard
            17763 { $GVLKey = 'N69G4-B89J2-4G8F4-WWYCC-J464C' }
            # Windows Server 2016 Standard
            14393 { $GVLKey = 'WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY' }
            # Windows Server 2012 R2 Standard
            9600 { $GVLKey = 'D2N9P-3P6X9-2R39C-7RTCD-MDVJX' }
        }
    }
}
# Else Workstation
else {
    switch ($OSCaption) {
        # Windows Enterprise
        { ($_ -eq 'Microsoft Windows 11 Enterprise') -and ($_ -eq 'Microsoft Windows 10 Enterprise') } { $GVLKey = 'NPPR9-FWDCX-D2C8J-H872K-2YT43' }
        # Windows Professional
        { ($_ -eq 'Microsoft Windows 11 Pro') -and ($_ -eq 'Microsoft Windows 10 Pro') } { $GVLKey = 'W269N-WFGWX-YVC9B-4J6C9-T83GX' }
        # LTSC 21H2 - 2021 / LTSC 1809 - 2019
        { ($_ -eq 'Microsoft Windows 10 Enterprise LTSC') -and (($OSBuildNumber -eq '19044') -or ($OSBuildNumber -eq '17763')) } { $GVLKey = 'M7XTQ-FN8P6-TTKYV-9D4CC-J462D' }
        # LTSB 2016
        { ($_ -eq 'Microsoft Windows 10 Enterprise 2016 LTSB') } { $GVLKey = 'DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ' }
        # LTSC 2015
        { ($_ -eq 'Microsoft Windows 10 Enterprise 2015 LTSB') -and ($OSBuildNumber -eq '19044') } { $GVLKey = '	WNMTR-4C88C-JK8YV-HQ7T2-76DF9' }
    }
}
#======================================================================================
#   Set SLMGR
#======================================================================================
if (Test-Path "$env:windir\SYSWOW64\slmgr.vbs") {
    $slmgr = "$env:windir\SYSWOW64\slmgr.vbs"
}
else {
    $slmgr = "$env:windir\System32\slmgr.vbs"
}
#======================================================================================
#   OS Activation
#======================================================================================
if ((Test-Path $slmgr) -and ($GVLKey)) {
    Write-Host "**********************"
    Write-Host "Display Licensing Information"
    Write-Host "Command Line: cscript //nologo $slmgr /dlv"
    cscript //nologo $slmgr /dlv
    Write-Host "**********************"
    Write-Host "Install Product Key"
    Write-Host "Command Line: cscript //nologo $slmgr /ipk $GVLKey"
    cscript //nologo $slmgr /ipk $GVLKey
    Write-Host "**********************"
    Write-Host "Activate Windows"
    Write-Host "Command Line: cscript //nologo $slmgr /ato"
    cscript //nologo $slmgr /ato
    Write-Host "**********************"
    Write-Host "Display Licensing Information"
    Write-Host "Command Line: cscript //nologo $slmgr /dlv"
    cscript //nologo $slmgr /dlv
    Write-Host "**********************"
    Write-Host "Display Installation ID for Offline Activation"
    Write-Host "Command Line: cscript //nologo $slmgr /dti"
    cscript //nologo $slmgr /dti
}
Write-Host "**********************"
Write-Warning "Internet access may be required to complete activation"
#======================================================================================
#   Complete
#======================================================================================
Stop-Transcript
