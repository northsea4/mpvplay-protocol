@echo off
setlocal EnableDelayedExpansion

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: This script requires Administrator privileges.
    echo Please right-click on this file and select "Run as Administrator".
    echo.
    pause
    exit /b 1
)

:: Check for MPV executable
if not exist "%~dp0mpv.exe" (
    echo Error: Cannot find mpvplay.exe
    echo Please put these files in your MPV directory and try again.
    echo.
    pause
    exit /b 1
)

echo Registering mpvplay:// protocol handler...
echo.

:: Register protocol handler
reg add "HKCR\mpvplay" /ve /t REG_SZ /d "URL:mpvplay Protocol" /f

reg add "HKCR\mpvplay" /v "URL Protocol" /t REG_SZ /d "" /f

reg add "HKCR\mpvplay\DefaultIcon" /ve /t REG_SZ /d "\"%~dp0mpv.exe\",0" /f

reg add "HKCR\mpvplay\shell\open\command" /ve /t REG_SZ /d "\"%~dp0mpvplay-protocol.bat\" \"%%1\"" /f

:: Verify registration
reg query "HKCR\mpvplay\shell\open\command" /ve
if %errorLevel% neq 0 (
    echo Error: Failed to verify registration.
    pause
    exit /b 1
)

echo Successfully registered mpvplay:// protocol handler!
echo You can now use mpvplay:// links in your browser.
echo.
pause
