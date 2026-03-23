@echo off
echo =========================================
echo Launching VedantaTrade Enterprise App...
echo =========================================
echo.

:: Ensure standard paths and git are included so flutter works
set PATH=%PATH%;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files\Git\cmd;C:\flutter\bin

echo Running flutter pub get...
call flutter pub get

echo.
echo Starting app on connected USB device...
call flutter run

echo.
echo =========================================
echo Session ended. Press any key to close.
pause
