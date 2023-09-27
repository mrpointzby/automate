$USB_BDF = Read-Host "usb bus.device.function"
bcdedit /debug on 
bcdedit /set "{dbgsettings}" busparams $USB_BDF
bcdedit /dbgsettings usb targetname:test
pause
