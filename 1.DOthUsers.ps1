bcdedit /set testsigning on

# Disable all user accounts except for Administrator
Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.Name -ne "Administrator" } | ForEach-Object {
    $user = [ADSI]("WinNT://./" + $_.Name)
    $user.UserFlags = 2
    $user.SetInfo()
}

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

    # write anEVt toSySt log
    wmic recoveros set WriteToSystemLog = True
    # AnOther
    # REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v LogEvent /t REG_DWORD /d 1 /f 
        
    #Auto ReStart Opt_
    REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v AutoReboot /t REG_DWORD /d 0 /f 
    # AnOther
    # wmic recoveros set AutoReboot = False

    # DebugInfoType (0,1,2,3,7) = (NoReCord,ComPlete,Kernel,Small,Automatic Memory Dump)
    wmic recoveros set DebugInfoType = 1
    REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 1 /f 

    # OverWrite Opt_
    wmic recoveros set OverwriteExistingDebugFile = 1
    # AnOther
    # REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v Overwrite /t REG_DWORD /d 1 /f 

    Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl"

    Copy-Item -Recurse .\VKEStress-v1.27_20150701 C:\Users\Administrator\Desktop\VKEStress


pause