@echo off
@echo.
if not exist "%~dp0mpvplay-protocol.exe" (
  echo Warning: Can't find mpvplay-protocol.exe.

  echo Did you compile it successfully?
  @echo.
  pause
  exit /b
)
if not exist "%~dp0mpv.exe" (
  echo Warning: Can't find mpv.exe.
  echo Please put these files in your MPV directory and then run this file.
  @echo.
  pause
  exit /b
)
echo If you see "ERROR: Access is denied." then you need to right click and use "Run as Administrator".
@echo.
echo Associating mpvplay:// with mpvplay-protocol.exe...

reg add HKCR\mpvplay /ve /t REG_SZ /d "URL:mpvplay Protocol" /f
reg add HKCR\mpvplay /v "URL Protocol" /t REG_SZ /d "" /f
reg add HKCR\mpvplay\DefaultIcon /ve /t REG_SZ /d "%~dp0mpv.exe,0" /f
reg add HKCR\mpvplay\shell\open\command /ve /t REG_SZ /d "\"%~dp0mpvplay-protocol.exe\" \"%%1\"" /f


@echo.
pause
