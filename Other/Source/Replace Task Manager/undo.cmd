ECHO OFF
COLOR F0
cls
echo.
set _ok=
set /p _ok=This will undo Process Hacker as default Task Manager, press "Y" to begin...
if /I NOT "%_ok%" == "Y" EXIT
REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v Debugger && GOTO CLN || GOTO NEXT
:CLN
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v Debugger /f
:NEXT
REG QUERY "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v Debugger && GOTO DEL || GOTO END
:DEL
REG DELETE "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v Debugger /f
:END