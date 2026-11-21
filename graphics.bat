@echo off
setlocal EnableExtensions EnableDelayedExpansion
title FiveM Graphics Profile Switcher

set "FIVEM=C:\Users\PC\AppData\Local\FiveM\FiveM.app" :: Change this to your path
set "PROFILES=C:\Users\PC\AppData\Local\FiveM\profiles" :: Change this to your path
set "FPS=%PROFILES%\fps"
set "QUANT=%PROFILES%\quant"
set "TEMP=%PROFILES%\_switch_temp"
set "STATE=%PROFILES%\_active_profile.txt"

:MENU
cls
echo =========================================
echo        FIVEM GRAPHICS PROFILE
echo =========================================
echo.

if exist "%STATE%" (
    set /p CURRENT=<"%STATE%"
    echo Current profile: !CURRENT!
) else (
    echo Current profile: Unknown
)

echo.
echo [1] FPS / Day-to-day graphics
echo [2] QuantV / Media graphics
echo [3] Exit
echo.
choice /C 123 /N /M "Select an option: "

if errorlevel 3 goto :EXIT
if errorlevel 2 (
    set "TARGET=%QUANT%"
    set "TARGETNAME=QuantV / Media"
    set "TARGETSHORT=QUANT"
    goto :SWITCH
)
if errorlevel 1 (
    set "TARGET=%FPS%"
    set "TARGETNAME=FPS / Day-to-day graphics"
    set "TARGETSHORT=FPS"
    goto :SWITCH
)

:SWITCH
if exist "%STATE%" (
    set /p CURRENT=<"%STATE%"
) else (
    set "CURRENT="
)

if /I "!CURRENT!"=="%TARGETNAME%" (
    cls
    echo =========================================
    echo          ALREADY ACTIVE
    echo =========================================
    echo.
    echo %TARGETNAME% is already active.
    echo.
    pause
    goto :MENU
)

if not exist "%FIVEM%" goto :ERROR_FIVEM
if not exist "%TARGET%" goto :ERROR_TARGET

for %%D in (citizen mods plugins) do (
    if not exist "%TARGET%\%%D" goto :ERROR_PROFILE
)

if exist "%TEMP%" (
    cls
    echo =========================================
    echo       TEMP FOLDER ALREADY EXISTS
    echo =========================================
    echo.
    echo %TEMP%
    echo.
    echo A previous switch may not have completed.
    echo Nothing has been changed.
    echo.
    pause
    goto :MENU
)

if /I "!CURRENT!"=="FPS / Day-to-day graphics" (
    set "OLDPROFILE=%FPS%"
) else if /I "!CURRENT!"=="QuantV / Media" (
    set "OLDPROFILE=%QUANT%"
) else if /I "!CURRENT!"=="QuantV / Media graphics" (
    set "OLDPROFILE=%QUANT%"
) else (
    set "OLDPROFILE="
)

if not defined OLDPROFILE (
    cls
    echo =========================================
    echo        CURRENT PROFILE UNKNOWN
    echo =========================================
    echo.
    echo The switcher does not know which profile is
    echo currently installed in FiveM.app.
    echo.
    echo If your current setup is FPS, press 1.
    echo If your current setup is QuantV, press 2.
    echo.
    echo Do NOT continue switching until you have
    echo selected the profile that is currently active.
    echo.
    pause
    goto :MENU
)

mkdir "%TEMP%" >nul 2>&1
if errorlevel 1 goto :ERROR_TEMP

cls
echo =========================================
echo        SWITCHING TO %TARGETNAME%
echo =========================================
echo.

echo [1/3] Moving active folders to temporary storage...
for %%D in (citizen mods plugins) do (
    if exist "%FIVEM%\%%D" (
        move "%FIVEM%\%%D" "%TEMP%\" >nul
        if errorlevel 1 goto :FAIL
        echo       OK - %%D
    )
)

echo.
echo [2/3] Installing %TARGETNAME%...
for %%D in (citizen mods plugins) do (
    move "%TARGET%\%%D" "%FIVEM%\" >nul
    if errorlevel 1 goto :FAIL
    echo       OK - %%D
)

echo.
echo [3/3] Returning old profile folders...
for %%D in (citizen mods plugins) do (
    if exist "%TEMP%\%%D" (
        move "%TEMP%\%%D" "%OLDPROFILE%\" >nul
        if errorlevel 1 goto :FAIL
        echo       OK - %%D
    )
)

rmdir "%TEMP%" >nul 2>&1

if exist "%TEMP%" goto :FAIL_CLEANUP

> "%STATE%" echo %TARGETNAME%

echo.
echo =========================================
echo          SWITCH COMPLETE
echo =========================================
echo.
echo Active profile: %TARGETNAME%
echo.
pause
goto :MENU

:FAIL
echo.
echo =========================================
echo          SWITCH FAILED
echo =========================================
echo.
echo A folder could not be moved.
echo.
echo TEMPORARY FILES HAVE NOT BEEN DELETED.
echo They are here:
echo %TEMP%
echo.
echo Check that location before doing anything else.
echo.
pause
goto :MENU

:FAIL_CLEANUP
echo.
echo =========================================
echo       SWITCH FINISHED WITH WARNING
echo =========================================
echo.
echo The switch completed, but the temporary folder
echo could not be removed:
echo %TEMP%
echo.
echo If it contains folders, they are the old profile
echo folders. Do not delete them until checked.
echo.
pause
goto :MENU

:ERROR_FIVEM
cls
echo ERROR: FiveM.app could not be found.
echo.
echo %FIVEM%
pause
goto :MENU

:ERROR_TARGET
cls
echo ERROR: The selected profile could not be found.
echo.
echo %TARGET%
pause
goto :MENU

:ERROR_PROFILE
cls
echo ERROR: The selected profile is missing one or more
echo required folders.
echo.
echo Required:
echo   citizen
echo   mods
echo   plugins
echo.
pause
goto :MENU

:ERROR_TEMP
cls
echo ERROR: Could not create temporary folder.
echo.
pause
goto :MENU

:EXIT
endlocal
exit /b
