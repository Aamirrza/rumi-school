@echo off
title School Management System Runner
echo =======================================================
echo Starting School Management System...
echo =======================================================
echo.

:: Open the browser immediately to the local URL
echo Opening web browser to http://localhost:5076...
start http://localhost:5076

:: Run the project in development mode
dotnet run --project src\SchoolManagement.Web\SchoolManagement.Web.csproj --launch-profile "http"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] The application failed to start.
    pause
)
