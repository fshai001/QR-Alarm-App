@echo off
setlocal
cd /d "%~dp0"

echo ============================================
echo  QR Alarm Clock - Fix Folder + Push to GitHub
echo ============================================
echo.

REM --- Step 1: Fix nested folder structure if needed ---
if exist "lib" (
    echo [OK] Found the "lib" folder here - structure looks correct.
) else (
    if exist "qr_alarm_clock\lib" (
        echo Found files nested one level too deep inside "qr_alarm_clock" - fixing...
        xcopy "qr_alarm_clock\*" "." /E /H /Y >nul
        rmdir /s /q "qr_alarm_clock"
        echo [OK] Fixed - files moved up to this folder.
    ) else (
        echo [ERROR] Could not find a "lib" folder here or inside a "qr_alarm_clock" folder.
        echo.
        echo Please make sure this .bat file is saved in the SAME folder
        echo where you unzipped the project files, then double-click it again.
        echo.
        pause
        exit /b 1
    )
)
echo.

REM --- Step 2: Check Git is installed ---
where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git is not installed on this computer.
    echo.
    echo Please install it first from: https://git-scm.com/download/win
    echo Just click through the installer with default options, then
    echo double-click this file again afterward.
    echo.
    pause
    exit /b 1
)
echo [OK] Git is installed.
echo.

REM --- Step 3: Re-initialize git and push ---
echo Removing any old/broken git history in this folder...
if exist ".git" rmdir /s /q ".git"

echo Initializing a fresh git repository...
git init
git add .
git commit -m "Initial commit: QR alarm clock source + build workflow"
git branch -M main

echo.
echo Connecting to your GitHub repository...
git remote remove origin 2>nul
git remote add origin https://github.com/fshai001/QR-Alarm-App.git

echo.
echo Pushing files to GitHub...
echo (A browser window may pop up asking you to sign in to GitHub - just log in there if so.)
echo.
git push -u origin main --force

echo.
echo ============================================
echo  Done! Now go check:
echo  https://github.com/fshai001/QR-Alarm-App
echo.
echo  Then click the "Actions" tab to run the build.
echo ============================================
echo.
pause
