Set-PSDebug -Trace 2

.\HE.exe

#CoreIsol_ReON
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f
#MicroSoft_ReDrivErBlockList
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 0 /f

pause