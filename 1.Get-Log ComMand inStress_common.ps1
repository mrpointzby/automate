#NeedTest

#DisPlay ComMand forTest
#CMD: @echo off
Set-PSDebug -Trace 2

#MicroSoft DrivEr_Block_Rules_RwDrv.sys
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 0 /f
#CoreIsol_Off
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f

#time
#CMD:change time

#--------------------------------------------------------------------------------
#-----------------------------This DiRect---------------------------------------

.\tool\CrystalDiskInfo8_17_13_B\DiskInfo64.exe /copyexit

<#
ReSet SeCureBootto En
"safe\MfgToolsBundle_12_April_2022\win64\PlatCfg2W64.exe" -set SecureBoot=Enabled
#>

explorer C:\DashClient\_DashMedia\Sequence\Content\Archive\0\results.json
msinfo32
eventvwr
& '.\0.5 Curr evtlog_FiltEr inXML.txt'

#SaveHere
#need test
.\tool\HE\HE.exe Load .\tool\HE\SMBIOS+CMOS+IntelRSTRegViaHE.cmd

<#
CMD:
    set /p "newfolder=Type folder name with mod+1BIOS+speci- sym-pto-: "
    mkdir "%newfolder%"
    cd "%newfolder%"
#>

$FoldEr = Read-Host -prompt "mod seri SymPto XXXX 0x test cycle(take ScreenShots first)"
new-item $FoldEr -type Directory
cd $FoldEr
#-------------------------------------------------------------------------------------------
#-----------------------------------new DiRect----------------------------------------------
powercfg /spr

#timezone > timezone.txt

#MoveDump
<#
    CMD_mand:
    if exist C:\Windows\MEMORY.DMP move C:\Windows\MEMORY.DMP 
    if exist C:\Windows\Minidump\*.dmp move C:\Windows\Minidump\*.dmp
#>
if (Test-Path C:\Windows\MEMORY.zip){Move-Item C:\Windows\MEMORY.zip}
if (Test-Path C:\Windows\MEMORY.DMP){Move-Item C:\Windows\MEMORY.DMP}
if (Test-Path C:\Windows\Minidump\*.dmp){Move-Item C:\Windows\Minidump\*.dmp}

msinfo32 /report MSINFO32.txt

#DiskC_Files
#CMDMand:   dir /s C:\ > CSubdirectory.txt
#Short-Term NoTime tocheck
#dir C:\ > CFiles.txt -Recurse

<#
EVtLog:    
    CMDMand:
    set /p "evtnewform=Type symptom with test:"
    wevtutil epl system "%evtnewform%.evtx"
#>

$evtlog = Read-Host -prompt "SymPto test"
wevtutil epl system "$evtlog.evtx"
wevtutil epl application "app.evtx"
wevtutil cl system

Move-Item '..\SMBIOS,CMOS,RSTReg.txt'
if(Test-Path $home\Pictures\Screenshots\*.png){
    Move-Item $home\Pictures\Screenshots\}
#todo:check

explorer.exe .

#HE or RW
cd \

#----------------------------------------------------------------------------------------------
#-------------------------------------Root DiRect---------------------------------------------

#moveto FoldeR:a need test
#CMDMand:   if exist a\CrystalDiskInfo8_17_13\DiskInfo.txt move a\CrystalDiskInfo8_17_13\DiskInfo.txt "a\%newfolder%"
if(Test-Path .\a\tool\CrystalDiskInfo8_17_13_B\DiskInfo.txt) {Move-Item .\a\tool\CrystalDiskInfo8_17_13_B\DiskInfo.txt ".\a\$FoldEr\DiskInfo.txt"}

#bsod_forensic_updatelatest
get-executionpolicy
set-executionpolicy RemoteSigned
#CMDCallPowerShell: powershell a\bsodIF_app.ps1 > "a\%newfolder%\bsod_Forensic.txt"
a\bsodIF_app.ps1 > "a\$FoldEr\bsod_Forensic.txt"

#FPT DownLoad BIOS_SPI
#"a\FPT tool\FPTW64.exe" -D "a\%newfolder%\BIOS_DUMP SPI.bin"
#need test
#& ".\a\tool\FPT tool_pass\FPTW64.exe" -D "a\$FoldEr\BIOS_DUMP SPI.bin"

#.\HE.exe
#call U:\HE.exe
#test: start /wait - test /s

#open LogCollectionTool.exe
"C:\Program Files\Dell\SARemediation\plugin\LogCollectionTool.exe"

#choose whether A_R_
<#
    CMDMand:
    choice /T 60 /D n /M "AutoRestart?" 
    if %errorlevel% EQU 1 goto LogCollecion
    if %errorlevel% EQU 2 goto PassLogCollecion
#>
#PSchoiceComMand???


<#
CMDBranch  :PassLogCollecion
txt file cre-
set /p notf=name of text file :
set /p cof=contents of file :
echo %cof%>>"%notf%.txt"
#>

#control hotplug.dll
#RunDll32.exe shell32.dll,Control_RunDLL hotplug.dll
#e-vent log oper- with para-meter

<#set /p "evtxinform=Type symptom with test:"
wevtutil epl system "%evtxinform%.evtx"
wevtutil epl /ow security c:\log.evtx
wevtutil epl c:\log.evtx
#>

#sy-st- file check-er
#sfc /scannow

#if exist C:\Windows\Logs\CBS\CBS.log move C:\Windows\Logs\CBS\CBS.log

<#
change toRealTime &DisPlay
tzutil /s "China Standard Time"
tzutil /g
time 
date
#>

#CoreIsol_ReON
#REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 1 /f
#MicroSoft_ReDrivErBlockList
#REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 1 /f

#NotDisApPear
pause




