@echo off
echo =========================================
echo VedantaTrade Wireless Debug Deployment
echo =========================================
echo.

:: Ensure standard paths and git are included so flutter works
set PATH=%PATH%;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files\Git\cmd;C:\flutter\bin

echo Checking Flutter installation...
call flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Cleaning previous build artifacts...
call flutter clean

echo.
echo Running flutter pub get...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Checking for connected devices...
call flutter devices

echo.
echo Setting up wireless debugging...
echo =========================================
echo IMPORTANT: Make sure your Android device is:
echo 1. Connected via USB initially
echo 2. Has USB debugging enabled
echo 3. Is on the same WiFi network as your computer
echo =========================================
echo.

echo Enabling wireless debugging on connected device...
call adb tcpip 5555
if %errorlevel% neq 0 (
    echo ERROR: Failed to enable wireless debugging
    echo Make sure your device is connected via USB with debugging enabled
    pause
    exit /b 1
)

echo.
echo Getting device IP address...
call adb shell ip addr show wlan0 | findstr "inet " > temp_ip.txt
for /f "tokens=2 delims= " %%i in (temp_ip.txt) do set DEVICE_IP=%%i
for /f "tokens=1 delims=/" %%i in ("%DEVICE_IP%") do set DEVICE_IP=%%i

if "%DEVICE_IP%"=="" (
    echo ERROR: Could not get device IP address
    echo Make sure WiFi is enabled on your device
    del temp_ip.txt 2>nul
    pause
    exit /b 1
)

echo Device IP: %DEVICE_IP%

echo.
echo Connecting to device wirelessly...
call adb connect %DEVICE_IP%:5555
if %errorlevel% neq 0 (
    echo ERROR: Failed to connect wirelessly
    del temp_ip.txt 2>nul
    pause
    exit /b 1
)

echo.
echo You can now disconnect the USB cable
echo Verifying wireless connection...
call adb devices

echo.
echo Building and deploying app in debug mode...
call flutter run -d %DEVICE_IP% --debug
if %errorlevel% neq 0 (
    echo ERROR: Failed to run app
    del temp_ip.txt 2>nul
    pause
    exit /b 1
)

:: Cleanup temporary files
if exist temp_ip.txt del temp_ip.txt





echo.
echo =========================================
echo Wireless debug deployment successful!
echo =========================================
echo.
echo App is now running on your device wirelessly
echo You can use 'flutter hot-reload' for code changes
echo Device IP: %DEVICE_IP%
echo.
echo To stop wireless debugging when done:
echo adb disconnect %DEVICE_IP%:5555
echo.

echo.
echo =========================================
echo Session ended. Press any key to close.
pause
