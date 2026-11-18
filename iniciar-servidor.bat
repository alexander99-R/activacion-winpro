@echo off
title Servidor Activacion WinPro - Taller
chcp 65001 >nul
color 0a
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
if %errorlevel% neq 0 (
    echo.
    echo [AVISO] El servidor se ha detenido.
    pause
)

