@echo off
:: Change drive to G: and enter the directory
cd /d G:\GitHub\Odysseus

:: Execute the PowerShell script
powershell -ExecutionPolicy Bypass -File .\launch-windows.ps1

pause