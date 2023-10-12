$ArrayDisk = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -ExpandProperty DeviceID
$i = 0
while($i -lt $ArrayDisk.Length){
copy-item -Recurse C:\Users\Brady\Desktop\Xter_tools_prototype\ "$($ArrayDisk[$i])\"
copy-item -Recurse C:\Users\Brady\Desktop\CurrentIssue\ "$($ArrayDisk[$i])\"
$i ++
}