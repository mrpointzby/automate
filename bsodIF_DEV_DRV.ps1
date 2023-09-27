#EFI_GUID    BsodForensicDumpVariableGuid = {0xa544a530, 0xb988, 0x4b87, {0xe1, 0xbb, 0x75, 0x34, 0xd3, 0x24, 0x32, 0x52}};
#CHAR16      *BsodForensicDumpVarName = L"BsodForensicDump";
#CHAR16      *BsodForensicDumpVarName2 = L"BsodForensicDump2";


$definition = @'
 using System;
 using System.Runtime.InteropServices;
 using System.Text;
   
 public class UEFINative
 {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern UInt32 GetFirmwareEnvironmentVariableA(string lpName, string lpGuid, [Out] Byte[] lpBuffer, UInt32 nSize);
 
        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern UInt32 NtEnumerateSystemEnvironmentValuesEx(UInt32 function, [Out] Byte[] lpBuffer, ref UInt32 nSize);
 }
'@

$uefiNative = Add-Type $definition -PassThru

$GUID_UEFIGlobal = "{8BE4DF61-93CA-11D2-AA0D-00E098032B8C}"
$GUID_UEFIWindows = "{77FA9ABD-0359-4D32-BD60-28F4E78F784B}"
$GUID_UEFISurface = "{D2E0B9C9-9860-42CF-B360-F906D5E0077A}"
$GUID_UEFITesting = "{1801FBE3-AEF7-42A8-B1CD-FC4AFAE14716}"
$GUID_UEFISecurityDatabase = "{d719b2cb-3d3a-4596-a3bc-dad00e67656f}"
$GUID_UEFIBsodForensic = "{A544A530-B988-4B87-E1BB-7534D3243252}"

function Get-UEFIVariable
{
<#
.SYNOPSIS
    Gets the value of the specified UEFI firmware variable.
 
.DESCRIPTION
    Gets the value of the specified UEFI firmware variable. This must be executed in an elevated process (requires admin rights).
 
.PARAMETER All
    Get the namespace and variable names for all available UEFI variables.
 
.PARAMETER Namespace
    A GUID string that specifies the specific UEFI namespace for the specified variable. Some predefined namespace global variables
    are defined in this module. If not specified, the UEFI global namespace ($UEFIGlobal) will be used.
 
.PARAMETER VariableName
    The name of the variable to be retrieved. This parameter is mandatory. An error will be returned if the variable does not exist.
 
.PARAMETER AsByteArray
    Switch to specify that the value of the specified UEFI variable should be returned as a byte array instead of as a string.
 
.EXAMPLE
    Get-UEFIVariable -All
 
.EXAMPLE
    Get-UEFIVariable -VariableName PlatformLang
 
.EXAMPLE
    Get-UEFIVariable -VariableName BootOrder -AsByteArray
 
.EXAMPLE
    Get-UEFIVariable -VariableName Blah -Namespace $UEFITesting
 
.OUTPUTS
    A string or byte array containing the current value of the specified UEFI variable.
 
.LINK
    https://oofhours.com/2019/09/02/geeking-out-with-uefi/
 
     
    https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getfirmwareenvironmentvariablea
 
#Requires -Version 2.0
#>

    [cmdletbinding()]  
    Param(
        [Parameter(ParameterSetName='All', Mandatory = $true)]
        [Switch]$All,

        [Parameter(ParameterSetName='Single', Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [String]$Namespace = $GUID_UEFIGlobal,

        [Parameter(ParameterSetName='Single', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [String]$VariableName,

        [Parameter(ParameterSetName='Single', Mandatory=$false)]
        [Switch]$AsByteArray = $false
    )

    BEGIN {
        $rc = Set-LHSTokenPrivilege -Privilege SeSystemEnvironmentPrivilege
    }
    PROCESS {
        if ($All) {
            # Get the full variable list
            $VARIABLE_INFORMATION_NAMES = 1
            $size = 1024 * 1024
            $result = New-Object Byte[]($size)
            $rc = $uefiNative[0]::NtEnumerateSystemEnvironmentValuesEx($VARIABLE_INFORMATION_NAMES, $result, [ref] $size)
            $lastError = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            
            Write-Output -InputObject $rc
            
            if ($rc -eq 0)
            {
                $currentPos = 0
                while ($true)
                {
                    # Get the offset to the next entry
                    $nextOffset = [System.BitConverter]::ToUInt32($result, $currentPos)
                    if ($nextOffset -eq 0)
                    {
                        break
                    }
    
                    # Get the vendor GUID for the current entry
                    $guidBytes = $result[($currentPos + 4)..($currentPos + 4 + 15)]
                    [Guid] $vendor = [Byte[]]$guidBytes
                    
                    # Get the name of the current entry
                    $name = [System.Text.Encoding]::Unicode.GetString($result[($currentPos + 20)..($currentPos + $nextOffset - 1)])
    
                    # Return a new object to the pipeline
                    New-Object PSObject -Property @{Namespace = $vendor.ToString('B'); VariableName = $name.Replace("`0","") }
    
                    # Advance to the next entry
                    $currentPos = $currentPos + $nextOffset
                }
            }
            else
            {
                Write-Error "Unable to retrieve list of UEFI variables, last error = $lastError."
            }
        }
        else {
            # Get a single variable value
            $size = 1024
            $result = New-Object Byte[]($size)
            $rc = $uefiNative[0]::GetFirmwareEnvironmentVariableA($VariableName, $Namespace, $result, $size)
            $lastError = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if ($lastError -eq 122)
            {
                # Data area passed wasn't big enough, try larger. Doing 32K all the time is slow, so this speeds it up.
                $size = 32*1024
                $result = New-Object Byte[]($size)
                $rc = $uefiNative[0]::GetFirmwareEnvironmentVariableA($VariableName, $Namespace, $result, $size)
                $lastError = [Runtime.InteropServices.Marshal]::GetLastWin32Error()    
            }
            if ($rc -eq 0)
            {
                Write-Error "Unable to retrieve variable $VariableName from namespace $Namespace, last error = $lastError."
                return ""
            }
            else
            {
                Write-Verbose "Variable $VariableName retrieved with $rc bytes"
                [System.Array]::Resize([ref] $result, $rc)
                if ($AsByteArray)
                {
                    return $result
                }
                else
                {
                    $enc = [System.Text.Encoding]::ASCII
                    return $enc.GetString($result)
                }
            }
        }

    }
    END {
        $rc = Set-LHSTokenPrivilege -Privilege SeSystemEnvironmentPrivilege -Disable
    }
}


function Set-LHSTokenPrivilege
{
<#
.SYNOPSIS
    Enables or disables privileges in a specified access token.
 
.DESCRIPTION
    Enables or disables privileges in a specified access token.
 
.PARAMETER Privilege
    The privilege to adjust. This set is taken from
    http://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
 
.PARAMETER ProcessId
    The process on which to adjust the privilege. Defaults to the current process.
 
.PARAMETER Disable
    Switch to disable the privilege, rather than enable it.
 
.EXAMPLE
    Set-LHSTokenPrivilege -Privilege SeRestorePrivilege
 
    To set the 'Restore Privilege' for the current Powershell Process.
 
.EXAMPLE
    Set-LHSTokenPrivilege -Privilege SeRestorePrivilege -Disable
 
    To disable 'Restore Privilege' for the current Powershell Process.
 
.EXAMPLE
    Set-LHSTokenPrivilege -Privilege SeShutdownPrivilege -ProcessId 4711
     
    To set the 'Shutdown Privilege' for the Process with Process ID 4711
 
.INPUTS
    None to the pipeline
 
.OUTPUTS
    System.Boolean, True if the privilege could be enabled
 
.NOTES
    to check privileges use whoami
    PS:\> whoami /priv
 
    PRIVILEGES INFORMATION
    ----------------------
 
    Privilege Name Description State
    ============================= ==================================== ========
    SeShutdownPrivilege Shut down the system Disabled
    SeChangeNotifyPrivilege Bypass traverse checking Enabled
    SeUndockPrivilege Remove computer from docking station Disabled
    SeIncreaseWorkingSetPrivilege Increase a process working set Disabled
 
 
    AUTHOR: Pasquale Lantella
    LASTEDIT:
    KEYWORDS: Token Privilege
 
.LINK
    http://www.leeholmes.com/blog/2010/09/24/adjusting-token-privileges-in-powershell/
 
    The privilege to adjust. This set is taken from
    http://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
 
    pinvoke AdjustTokenPrivileges (advapi32)
    http://www.pinvoke.net/default.aspx/advapi32.AdjustTokenPrivileges
 
#Requires -Version 2.0
#>
   
[cmdletbinding(  
    ConfirmImpact = 'low',
    SupportsShouldProcess = $false
)]  

[OutputType('System.Boolean')]

Param(

    [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$False,HelpMessage='An Token Privilege.')]
    [ValidateSet(
        "SeAssignPrimaryTokenPrivilege", "SeAuditPrivilege", "SeBackupPrivilege",
        "SeChangeNotifyPrivilege", "SeCreateGlobalPrivilege", "SeCreatePagefilePrivilege",
        "SeCreatePermanentPrivilege", "SeCreateSymbolicLinkPrivilege", "SeCreateTokenPrivilege",
        "SeDebugPrivilege", "SeEnableDelegationPrivilege", "SeImpersonatePrivilege", "SeIncreaseBasePriorityPrivilege",
        "SeIncreaseQuotaPrivilege", "SeIncreaseWorkingSetPrivilege", "SeLoadDriverPrivilege",
        "SeLockMemoryPrivilege", "SeMachineAccountPrivilege", "SeManageVolumePrivilege",
        "SeProfileSingleProcessPrivilege", "SeRelabelPrivilege", "SeRemoteShutdownPrivilege",
        "SeRestorePrivilege", "SeSecurityPrivilege", "SeShutdownPrivilege", "SeSyncAgentPrivilege",
        "SeSystemEnvironmentPrivilege", "SeSystemProfilePrivilege", "SeSystemtimePrivilege",
        "SeTakeOwnershipPrivilege", "SeTcbPrivilege", "SeTimeZonePrivilege", "SeTrustedCredManAccessPrivilege",
        "SeUndockPrivilege", "SeUnsolicitedInputPrivilege")]
    [String]$Privilege,

    [Parameter(Position=1)]
    $ProcessId = $pid,

    [Switch]$Disable
   )

BEGIN {

    Set-StrictMode -Version Latest
    ${CmdletName} = $Pscmdlet.MyInvocation.MyCommand.Name

## Taken from P/Invoke.NET with minor adjustments.

$definition = @'
 using System;
 using System.Runtime.InteropServices;
   
 public class AdjPriv
 {
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
   
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
 
  [DllImport("advapi32.dll", SetLastError = true)]
  internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
 
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct TokPriv1Luid
  {
   public int Count;
   public long Luid;
   public int Attr;
  }
   
  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
  internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
  internal const int TOKEN_QUERY = 0x00000008;
  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
 
  public static bool EnablePrivilege(long processHandle, string privilege, bool disable)
  {
   bool retVal;
   TokPriv1Luid tp;
   IntPtr hproc = new IntPtr(processHandle);
   IntPtr htok = IntPtr.Zero;
   retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
   tp.Count = 1;
   tp.Luid = 0;
   if(disable)
   {
    tp.Attr = SE_PRIVILEGE_DISABLED;
   }
   else
   {
    tp.Attr = SE_PRIVILEGE_ENABLED;
   }
   retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
   retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
   return retVal;
  }
 }
'@



} # end BEGIN

PROCESS {

    $processHandle = (Get-Process -id $ProcessId).Handle
    
    $type = Add-Type $definition -PassThru
    $type[0]::EnablePrivilege($processHandle, $Privilege, $Disable)

} # end PROCESS

END { Write-Verbose "Function ${CmdletName} finished." }

} # end Function Set-LHSTokenPrivilege


#_____________________

ls "HKLM:\SYSTEM\CurrentControlSet\" -Recurse | Get-ItemProperty 
# DEV

pnputil /enum-drivers
# DRV

$TryThisOneGuid = "{ba57e015-65b3-4c3c-b274-659192f699e3}"
$TryThisOneName = "BugCheckParameter1"   
Get-UEFIVariable -VariableName $TryThisOneName -Namespace $TryThisOneGuid -AsByteArray |Format-Hex

Get-UEFIVariable -VariableName BsodForensicDumpVarName -Namespace $GUID_UEFIBsodForensic

Get-UEFIVariable -all

Write-Host "BsodForensicDump:`r`n"

Get-UEFIVariable -VariableName BsodForensicDump -Namespace $GUID_UEFIBsodForensic

Write-Host "BsodForensicDump2:`r`n"

Get-UEFIVariable -VariableName BsodForensicDump2 -Namespace $GUID_UEFIBsodForensic


