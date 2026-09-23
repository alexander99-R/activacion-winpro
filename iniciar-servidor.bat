@echo off
title Servidor Activacion WinPro - Taller
color 0b
cd /d "%~dp0"
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: 1. Verificar si ya se esta ejecutando como Administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ======================================================================
    echo  SOLICITANDO PERMISOS DE RED LOCAL (WI-FI)...
    echo  (Para que celulares y otras laptops puedan conectarse al taller)
    echo.
    echo  Por favor haz clic en "SI" en la ventana de confirmacion de Windows.
    echo ======================================================================
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList '/k cd /d \"\"%SCRIPT_DIR%\"\" ^&^& \"\"%~f0\"\" __ELEVATED__' -Verb RunAs" 2>nul
    if %errorlevel% equ 0 exit /b
    echo.
    echo [AVISO] No se otorgaron permisos de Administrador.
    echo Iniciando en modo local estandar...
    echo.
)

cls
echo ======================================================================
echo   INICIANDO SERVIDOR ACTIVACION WINPRO EN ESTA PC...
echo ======================================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\server.ps1"
if %errorlevel% neq 0 (
    echo.
    echo [AVISO] El servidor se ha detenido o se cerro la ventana.
    pause
)
