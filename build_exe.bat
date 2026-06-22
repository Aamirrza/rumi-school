@echo off
title School Management System Builder
echo =======================================================
echo Building Standalone Package "SchoolManagementApp"...
echo =======================================================
echo.

:: Clean up old folders
if exist SchoolManagementApp (
    echo Cleaning up old SchoolManagementApp folder...
    rmdir /s /q SchoolManagementApp
)
if exist publish (
    rmdir /s /q publish
)

:: Publish the web application
echo Publishing project...
dotnet publish src\SchoolManagement.Web\SchoolManagement.Web.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:PublishReadyToRun=true -o .\SchoolManagementApp

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Build failed! Make sure the web server is stopped.
    pause
    exit /b %ERRORLEVEL%
)

:: Create the StartApp.bat inside the output folder
echo Creating launcher script...
(
echo @echo off
echo title School Management System
echo echo =============================================
echo echo Starting School Management System...
echo echo =============================================
echo echo Opening browser to http://localhost:5000...
echo start http://localhost:5000
echo SchoolManagement.Web.exe --urls "http://localhost:5000"
echo pause
) > SchoolManagementApp\StartApp.bat

echo.
echo =======================================================
echo [SUCCESS] Package Ready!
echo =======================================================
echo.
echo You can share the "SchoolManagementApp" folder.
echo To run it, just open the folder and double-click "StartApp.bat".
echo.
pause
