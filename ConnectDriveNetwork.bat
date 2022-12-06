@echo off
TITLE Connect Drive Network - Chibi ANUBIS
COLOR F0
PUSHD %TEMP%
SET KEYREGISTRY=HKEY_CURRENT_USER\SOFTWARE\ConnectDriveNetwork
reg query "%KEYREGISTRY%" >nul 2>nul
IF %ERRORLEVEL%==1 exit
ECHO Preparing...
SET var=1
SET SHAREREG=%KEYREGISTRY%\%var%
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
)
for /f "Tokens=2,*" %%G in ('reg query "%KEYREGISTRY%" /v "USERNAME" 2^> nul ') DO (SET USERNAME=%%H)
for /f "Tokens=2,*" %%G in ('reg query "%KEYREGISTRY%" /v "PWD" 2^> nul ') DO (SET PWD=%%H)
for /f "Tokens=2,*" %%G in ('reg query "%KEYREGISTRY%" /v "LOCALACCOUNT"') DO (SET LOCALACCOUNT=%%H)

:LoopDriveConnect
reg query "%SHAREREG%" /v Activated | find "0x1" >nul 2>nul
IF %ERRORLEVEL%==1 CALL :NetWorkIncrement
for /f "Tokens=2,*" %%G in ('reg query "%SHAREREG%" /v "LETTER"') DO (SET LETTER=%%H)
for /f "Tokens=2,*" %%G in ('reg query "%SHAREREG%" /v "NETWORK"') DO (SET NETWORK=%%H)
ECHO.
ECHO ***************************************
ECHO Connecting Drive %LETTER%: Please Wait ...
ECHO ***************************************
NET USE | find "%LETTER%:" >nul 2>nul
IF %ERRORLEVEL%==0 NET USE "%LETTER%:" /delete /y >nul 2>nul
IF %LOCALACCOUNT%==yes (
NET USE "%LETTER%:" "%NETWORK%" >nul 2>nul
)
IF  %LOCALACCOUNT%==no (
NET USE "%LETTER%:" "%NETWORK%" /USER:"%USERNAME%" "%PWD%" >nul 2>nul
)
IF %ERRORLEVEL%==0 (
call :chooseColor FA "SUCCESS"
echo.
) ELSE (
call :chooseColor FC "ERROR"
echo.
)
CALL :NetWorkIncrement
exit

:NetWorkIncrement
SET /a var=%var%+1
SET SHAREREG=%KEYREGISTRY%\%var%
reg query "%SHAREREG%" >nul 2>nul
IF %ERRORLEVEL%==0 goto LoopDriveConnect
goto :EOF

:chooseColor
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i
goto :EOF