@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

cd ../ane_src
call swcCompiler.bat
cd ../as3_demo
call copyANE.bat

echo.
echo Starting AIR Debug Launcher...
echo.

adl "%APP_XML%" "%APP_DIR%" -extdir extension/debug
if errorlevel 1 goto error
goto end

:error
pause

:end