<#
    todo: tube to simplify
    todo: function to simplify all I have done
    todo: multiple functions to operate
#>
function LeftShift {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Operand,

        [Parameter(Mandatory=$true)]
        [int]$OperateCount
    )
    echo "Operate on Base 10"
    echo "Operand input int value is $Operand"
    echo "OperateCount input int value is $OperateCount"
    $result = $Operand -shl $OperateCount
    return $result
}

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



$BDF = read-host -Prompt "input <bus> <device> <function> (split by space)(as HEX)"
$ArrayBDF = $BDF -split ‘ ’ | foreach-object {$_}
$Bus_Base10 = ConvertToBase10 -OrigBase 16 -Operand $($ArrayBDF)[0]
$Bus_operate = LeftShift -Operand $Bus_Base10 -OperateCount 20
#$Bus_addr = ConvertFromBase10 -ResultBase 16 -Operand $Bus_operate
$Device_Base10 = ConvertToBase10 -OrigBase 16 -Operand $($ArrayBDF)[1]
$Device_operate = LeftShift -Operand $Device_Base10 -OperateCount 15
$Function_Base10 = ConvertToBase10 -OrigBase 16 -Operand $($ArrayBDF)[2]
$Function_operate = LeftShift -Operand $Function_Base10 -OperateCount 12

# todo: how to retrieve PCIe base address?