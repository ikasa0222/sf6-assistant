@echo off
chcp 65001 >nul
title SF6 Assistant - Local APK Builder

echo ==================================================
echo   街霸6助手 (SF6 Assistant) 本地 APK 快速编译
echo ==================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_apk.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] 编译过程中遇到错误，退出代码: %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [SUCCESS] 本地 APK 编译成功！
pause
