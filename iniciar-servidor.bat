@echo off
title Servidor Activacion WinPro - Taller
color 0b
cd /d "%~dp0"
echo ==============================================================
echo  INICIANDO SERVIDOR ACTIVACION WINPRO EN ESTA PC...
echo ==============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
if %errorlevel% neq 0 (
    echo.
    echo [AVISO] El servidor se ha detenido o se cerro la ventana.
    pause
)
