<#
    todo: tube to simplify
    todo: function to simplify all I have done
    todo: multiple functions to operate
#>

# input: -Operand -OperateCount
function LeftShift {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Operand,

        [Parameter(Mandatory=$true)]
        [int]$OperateCount
    )
    $result = $Operand -shl $OperateCount
    return $result
}

# input: -OrigBase -Operand
function ConvertToBase10{
    param(
        [Parameter(Mandatory=$true)]
        [int]$OrigBase,
        [Parameter(Mandatory=$true)]
        $Operand
    )
    $result = [convert]::toUInt64($Operand,$OrigBase)
    return $result
}

# input: -ResultBase -Operand
function ConvertFromBase10{
    param(
        [Parameter(Mandatory=$true)]
        [int]$ResultBase,
        [Parameter(Mandatory=$true)]
        [int]$Operand
    )
    $result = [convert]::tostring($Operand,$ResultBase)
    return $result
}

# input: -inputBaseX -LeftShiftCount
function LSConvertToAddr{
    param(
        [Parameter(Mandatory=$true)]
        $inputBaseX,
        [Parameter(Mandatory=$true)]
        [int]$LeftShiftCount
    )

    $Base10 = ConvertToBase10 -OrigBase 16 -Operand $inputBaseX
    $LShift = LeftShift -Operand $Base10 -OperateCount $LeftShiftCount
    $Addr = ConvertFromBase10 -ResultBase 16 -Operand $LShift

    return $Addr

    
}

# input: -HEX1 -HEX2
function HEXAdd{
    param(
        [Parameter(Mandatory=$true)]
        $HEX1,
        [Parameter(Mandatory=$true)]
        $HEX2
    )
    $dec1 = [System.Convert]::toInt64($HEX1,16)
    $dec2 = [System.Convert]::toInt64($HEX2,16)
    $DecResult = $dec1 + $dec2
# todo: extend to any operations on HEX
# todo: extend to any number of operands
    $result = [System.Convert]::tostring($DecResult,16)
    return $result
}

<# todo: set default arrays as input to check value 1 bit
function CheckVal1Bit{
    param(
        [Parameter(Mandatory=$true)]
        ()
        )
}
#>


$BDF = read-host -Prompt "input <bus> <device> <function> (split by space)(as HEX)"
$ArrayBDF = $BDF -split ‘ ’ | foreach-object {$_}
echo "<bus> LeftShift -shl 20, <device> Left Shift 15, <function> left shift 12"
$i = 0
$result = @()
$result = @("Bus","Device","Function")
# create an operated array from orignal BDF
# todo: most simpliest way to loop for 3 times
# todo: simplify the archetecture
while($i -le $ArrayBDF.GetUpperBound(0)){
    switch($i){
    {$_ -eq 0}
        {$result[$i] = LSConvertToAddr -inputBaseX $ArrayBDF[$_] -LeftShiftCount 20}
    {$_ -eq 1}
        {$result[$i] = LSConvertToAddr -inputBaseX $ArrayBDF[$_] -LeftShiftCount 15}
    {$_ -eq 2}
        {$result[$i] = LSConvertToAddr -inputBaseX $ArrayBDF[$_] -LeftShiftCount 12}
    }
    $i++
}
$resultAddr = HEXAdd $result[0] $result[1]
$resultAddr = HEXAdd $resultAddr $result[2]
echo $resultAddr
# also $array.length and $array.count

<#
$result = @()
$i = 0
while($i -le $ArrayBDF.Length){
    $result += $($ArrayBDF)[i]
    $i++
}
#>


# todo: how to retrieve PCIe base address?



