# Enable the Administrator account
$user = [ADSI]("WinNT://./Administrator")
$user.UserFlags = 0x10000
$user.SetInfo()