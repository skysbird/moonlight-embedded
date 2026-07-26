$ErrorActionPreference = 'SilentlyContinue'
Stop-Service -Name SunshineService -Force
Start-Sleep -Seconds 2
Start-Process -FilePath "$env:WINDIR\System32\DisplaySwitch.exe" -ArgumentList '/internal' -WindowStyle Hidden
Start-Sleep -Seconds 3
Start-Service -Name SunshineService
