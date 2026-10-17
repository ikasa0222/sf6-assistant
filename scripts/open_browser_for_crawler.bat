@echo off
chcp 65001 >nul
title Supercombo Wiki - CDP Crawler Browser Launcher

echo =======================================================
echo   街霸6 Supercombo Wiki 爬虫专属调试浏览器启动器
echo =======================================================
echo.
echo 正在启动独立调试版 Edge 浏览器 (端口: 9222)...
echo.

set "EDGE_PATH=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE_PATH%" (
    set "EDGE_PATH=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

if not exist "%EDGE_PATH%" (
    echo [ERROR] 未找到 Edge 浏览器，请确认安装路径！
    pause
    exit /b 1
)

start "" "%EDGE_PATH%" --remote-debugging-port=9222 --user-data-dir="%TEMP%\sf6_edge_profile" "https://wiki.supercombo.gg/w/Street_Fighter_6"

echo ✔ 浏览器已成功在 9222 调试端口启动！
echo ✔ 请在打开的浏览器页面中确认 Supercombo Wiki 正常加载（若有 Cloudflare 盾请点击验证）。
echo ✔ 页面加载完成后，请回到助手终端，我将立即开始自动爬取！
echo.
pause
