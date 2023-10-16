<#V1:
$ArrayDisk = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -ExpandProperty DeviceID
$i = 0
while($i -lt $ArrayDisk.Length){
copy-item -Recurse C:\Users\Brady\Desktop\Xter_tools_prototype\ "$($ArrayDisk[$i])\"
copy-item -Recurse C:\Users\Brady\Desktop\CurrentIssue\ "$($ArrayDisk[$i])\"
$i ++
}
#>

$ArrayDisk = Get-PSDrive -PSProvider FileSystem | where {$_.Free -gt 200GB} | select -ExpandProperty Root
$i = 0
while($i -lt $ArrayDisk.Length){
    copy-item -Recurse C:\Users\Brady\Desktop\Xter_tools_prototype\ "$($ArrayDisk[$i])"
    copy-item -Recurse C:\Users\Brady\Desktop\CurrentIssue\ "$($ArrayDisk[$i])"
}

# OneDrive Transport
copy-item -Recurse C:\Users\Brady\Desktop\CurrentIssue\ "C:\Users\Brady\OneDrive - Foxconn\文件"
copy-item -Recurse C:\Users\Brady\Desktop\Xter_tools_prototype\ "C:\Users\Brady\OneDrive - Foxconn\文件"
copy-item -Recurse C:\Users\Brady\Desktop\WorkAndHome\ "C:\Users\Brady\OneDrive - Foxconn\文件"