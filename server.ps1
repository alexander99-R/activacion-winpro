# ==============================================================================
# SERVIDOR HTTP LOCAL PARA ACTIVACION WINPRO - TALLER
# Arquitectura: PowerShell Core / Windows PowerShell
# Soporta: Archivos estaticos + API REST /api/db para base de datos compartida
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$baseDir = $PSScriptRoot
if (-not $baseDir) { $baseDir = Get-Location }

$port = 8080
$dbFile = Join-Path $baseDir "database.json"

# Obtener IPs locales de la máquina
$ipList = @()
try {
    $ipList = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
              Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | 
              Select-Object -ExpandProperty IPAddress
} catch {}

$listener = New-Object System.Net.HttpListener
$networkMode = $false

# 1. Intentar iniciar con acceso de red local (requiere Admin o regla de URL)
try {
    $listener.Prefixes.Add("http://+:$port/")
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Prefixes.Add("http://127.0.0.1:$port/")
    $listener.Start()
    $networkMode = $true
} catch {
    # 2. Si no tiene permisos de administrador, iniciar en MODO LOCAL (100% garantizado sin permisos)
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:${port}/")
    $listener.Prefixes.Add("http://127.0.0.1:${port}/")
    try {
        $listener.Start()
        $networkMode = $false
    } catch {
        Write-Host "Error al iniciar el servidor en el puerto ${port}: $_" -ForegroundColor Red
        Write-Host "Revisa si ya tienes otra ventana del servidor abierta."
        Read-Host "Presiona Enter para cerrar esta ventana..."
        exit 1
    }
}

Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   SISTEMA ACTIVACION WINPRO - SERVIDOR DEL TALLER (ACTIVO)           " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " En esta computadora ingresa a: " -NoNewline
Write-Host "http://localhost:$port/" -ForegroundColor Yellow
Write-Host ""
if ($networkMode) {
    if ($ipList.Count -gt 0) {
        Write-Host " Desde otras computadoras o teléfonos en el Wi-Fi del taller:" -ForegroundColor White
        foreach ($ip in $ipList) {
            Write-Host "   -> http://${ip}:${port}/" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host " [MODO LOCAL ACTIVO]: Sistema funcionando al 100% en esta PC." -ForegroundColor Green
    Write-Host " Si deseas conectar otras computadoras o celulares en el Wi-Fi:" -ForegroundColor DarkYellow
    Write-Host " Haz clic derecho en 'iniciar-servidor.bat' y elige 'Ejecutar como administrador'." -ForegroundColor DarkYellow
}
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " Base de datos central: $dbFile" -ForegroundColor Gray
Write-Host " [Mantén esta ventanita abierta mientras usen el sistema en el taller]" -ForegroundColor DarkGreen
Write-Host " Para detener el servidor: Cierra esta ventana." -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Abrir el navegador automáticamente en esta máquina
try {
    Start-Process "http://localhost:$port/"
} catch {}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # Cabeceras CORS para permitir conexiones desde cualquier dispositivo local
        $response.AddHeader("Access-Control-Allow-Origin", "*")
        $response.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        $response.AddHeader("Access-Control-Allow-Headers", "Content-Type")

        if ($request.HttpMethod -eq "OPTIONS") {
            $response.StatusCode = 200
            $response.Close()
            continue
        }

        $urlPath = $request.Url.LocalPath.TrimStart('/')

        # ------------------------------------------------------------------
        # API DE BASE DE DATOS (/api/db) - SINCRONIZACIÓN EN TIEMPO REAL
        # ------------------------------------------------------------------
        if ($urlPath -eq "api/db") {
            $response.ContentType = "application/json; charset=utf-8"
            
            if ($request.HttpMethod -eq "GET") {
                if (Test-Path $dbFile) {
                    $jsonBytes = [System.IO.File]::ReadAllBytes($dbFile)
                    $response.OutputStream.Write($jsonBytes, 0, $jsonBytes.Length)
                } else {
                    $emptyBytes = [System.Text.Encoding]::UTF8.GetBytes('{"status":"empty"}')
                    $response.OutputStream.Write($emptyBytes, 0, $emptyBytes.Length)
                }
                $response.Close()
                continue
            }
            elseif ($request.HttpMethod -eq "POST") {
                $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
                $body = $reader.ReadToEnd()
                if ($body -and $body.Trim().Length -gt 10) {
                    [System.IO.File]::WriteAllText($dbFile, $body, [System.Text.Encoding]::UTF8)
                    $respBytes = [System.Text.Encoding]::UTF8.GetBytes('{"success":true,"message":"Guardado en disco del taller"}')
                    $response.OutputStream.Write($respBytes, 0, $respBytes.Length)
                } else {
                    $response.StatusCode = 400
                }
                $response.Close()
                continue
            }
        }

        # ------------------------------------------------------------------
        # ARCHIVOS ESTÁTICOS
        # ------------------------------------------------------------------
        if ([string]::IsNullOrEmpty($urlPath) -or $urlPath -eq '/') {
            $urlPath = "index.html"
        }

        $filePath = Join-Path $baseDir $urlPath
        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            
            if ($filePath.EndsWith(".html")) {
                $response.ContentType = "text/html; charset=utf-8"
                $response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate")
            } elseif ($filePath.EndsWith(".css")) {
                $response.ContentType = "text/css"
            } elseif ($filePath.EndsWith(".js")) {
                $response.ContentType = "application/javascript"
            } elseif ($filePath.EndsWith(".json")) {
                $response.ContentType = "application/json; charset=utf-8"
            } else {
                $response.ContentType = "application/octet-stream"
            }

            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("404 No encontrado")
            $response.OutputStream.Write($msg, 0, $msg.Length)
        }
        $response.Close()
    } catch {
        # Manejar desconexiones de clientes
    }
}
