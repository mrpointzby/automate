#toMulti:
while(1){

#Set-PSDebug -Trace 2

$In_0 = Read-Host -Prompt "InPut value"
$In_Base = Read-Host -Prompt "InPut base from 2 or 10 or 16"

$Out_Base = Read-Host -Prompt "OutPut base to 2/10/16"

$base10 = [convert]::toUInt64("$In_0",$In_Base)

$Out = [convert]::tostring("$base10",$Out_Base)
echo "converted value in base $Out_Base is $Out"

$OutAsSinL = $Out.ToCharArray()
<#OtherWays for .ToCharArray()
$<String> -split "\D"

#>

$i = 0

Write-Host "Valu1 Bit:"
while($i -le $OutAsSinL.GetUpperBound(0)){
<#OtherWays for.GetUpperBound(0):
    .Length
    .Count
#>

    if($OutAsSinL[$i] -eq "1"){
    write-host "Bit $($OutAsSinL.GetUpperBound(0)-$i) valuis $($OutAsSinL[$i])"
    }     
    $i++
}

}
