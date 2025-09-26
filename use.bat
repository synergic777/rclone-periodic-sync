@echo off
SET SRC=%~dp0rclone.lnk
SET DEST=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\rclone.lnk

IF EXIST "%SRC%" (
    COPY /Y "%SRC%" "%DEST%"
    ECHO rclone.lnk has been copied to Startup.
    REM Open the Startup folder in File Explorer
    START "" "C:\Users\noisy\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
) ELSE (
    ECHO rclone.lnk does not exist in the current directory.
)
PAUSE
