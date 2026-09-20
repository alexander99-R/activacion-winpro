@echo off
chcp 65001 >nul
title Subir Cambios a GitHub - Activacion WinPro
echo ========================================================
echo   Activacion WinPro - Subir / Sincronizar con GitHub
echo ========================================================
echo.
git add .
git commit -m "Actualizacion del sistema"
git push -u origin main
echo.
echo ========================================================
echo   Proceso finalizado.
echo ========================================================
pause
