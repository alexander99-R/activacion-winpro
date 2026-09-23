# ==============================================================================
# SERVIDOR HTTP LOCAL PARA ACTIVACION WINPRO - TALLER
# Arquitectura: PowerShell Core / Windows PowerShell
# Soporta: Archivos estaticos + API REST /api/db para base de datos compartida
#          API REST /api/info para descubrimiento de red y enlace de celulares
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$baseDir = $PSScriptRoot
if (-not $baseDir) { $baseDir = Get-Location }

$port = 8080
$dbFile = Join-Path $baseDir "database.json"

# 1. Comprobar si se ejecuta con permisos de Administrador
$isAdmin = $false
try {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch {}

# Si somos Administrador, abrir Firewall y registrar URL ACL para permitir conexiones de celulares
if ($isAdmin) {
    try {
        netsh advfirewall firewall show rule name="WinPro Taller 8080" >$null 2>&1
        if ($LASTEXITCODE -ne 0) {
            netsh advfirewall firewall add rule name="WinPro Taller 8080" dir=in action=allow protocol=TCP localport=$port profile=any >$null 2>&1
        }
    } catch {}
    try {
        netsh http add urlacl url="http://+:${port}/" sddl="D:(A;;GX;;;WD)" >$null 2>&1
    } catch {}
} else {
    # Si no somos administrador, verificar si ya podemos escuchar en toda la red
    $canBindNetwork = $false
    try {
        $testL = New-Object System.Net.HttpListener
        $testL.Prefixes.Add("http://+:${port}/")
        $testL.Start()
        $testL.Stop()
        $canBindNetwork = $true
    } catch {}

    # Si aún no tenemos permisos de red, solicitar elevación automáticamente si es interactivo
    if (-not $canBindNetwork -and [Environment]::UserInteractive -and -not $env:WINPRO_NO_ELEVATE) {
        try {
            $scriptPath = $PSCommandPath
            if (-not $scriptPath) { $scriptPath = Join-Path $baseDir "server.ps1" }
            $proc = Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -PassThru -ErrorAction Stop
            if ($proc) {
                exit 0
            }
        } catch {
            # Si el usuario canceló el diálogo o no es interactivo, continúa normalmente en modo local
        }
    }
}

# 2. Obtener IPs locales de la máquina (priorizando Wi-Fi o Ethernet activa)
$ipList = [System.Collections.Generic.List[string]]::new()
$primaryIp = ""

try {
    $defRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1
    if ($defRoute) {
        $activeIps = Get-NetIPAddress -InterfaceIndex $defRoute.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
                     Where-Object { $_.IPAddress -notmatch "^127\." -and $_.IPAddress -notmatch "^169\.254\." } | 
                     Select-Object -ExpandProperty IPAddress
        foreach ($ip in $activeIps) {
            if ($ip -and -not $ipList.Contains($ip)) {
                $ipList.Add($ip)
                if (-not $primaryIp) { $primaryIp = $ip }
            }
        }
    }
} catch {}

try {
    $allIps = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
              Where-Object { $_.IPAddress -notmatch "^127\." -and $_.IPAddress -notmatch "^169\.254\." } | 
              Select-Object -ExpandProperty IPAddress
    foreach ($ip in $allIps) {
        if ($ip -and -not $ipList.Contains($ip)) {
            $ipList.Add($ip)
            if (-not $primaryIp) { $primaryIp = $ip }
        }
    }
} catch {}

if (-not $primaryIp) { $primaryIp = "localhost" }

# 3. Inicializar HttpListener
$listener = New-Object System.Net.HttpListener
$networkMode = $false

# Intentar escuchar en toda la red local (+)
try {
    $listener.Prefixes.Add("http://+:${port}/")
    $listener.Start()
    $networkMode = $true
} catch {
    # Si no tiene permisos de red amplia, iniciar en modo loopback local
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:${port}/")
        $listener.Prefixes.Add("http://127.0.0.1:${port}/")
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

if ($networkMode -and $primaryIp -ne "localhost") {
    Write-Host " [MODO RED LOCAL WI-FI ACTIVADO CON ÉXITO]" -ForegroundColor Green
    Write-Host ""
    Write-Host " >>> ENLACE PARA CELULARES Y OTRAS COMPUTADORAS (WI-FI) <<<" -ForegroundColor Yellow
    Write-Host "     http://${primaryIp}:${port}/" -ForegroundColor Yellow
    Write-Host ""
    if ($ipList.Count -gt 1) {
        Write-Host " Otras IPs de red disponibles:" -ForegroundColor Gray
        foreach ($otherIp in $ipList) {
            if ($otherIp -ne $primaryIp) {
                Write-Host "   - http://${otherIp}:${port}/" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }
    Write-Host " En esta computadora ingresa a: " -NoNewline
    Write-Host "http://${primaryIp}:${port}/" -ForegroundColor Yellow
} else {
    Write-Host " [MODO LOCAL ACTIVO]: Sistema funcionando al 100% en esta PC." -ForegroundColor Yellow
    Write-Host " En esta computadora ingresa a: http://localhost:${port}/" -ForegroundColor Yellow
    Write-Host ""
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
    if ($networkMode -and $primaryIp -ne "localhost") {
        Start-Process "http://${primaryIp}:${port}/"
    } else {
        Start-Process "http://localhost:${port}/"
    }
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
        # API DE INFORMACIÓN DE RED (/api/info)
        # ------------------------------------------------------------------
        if ($urlPath -eq "api/info") {
            $response.ContentType = "application/json; charset=utf-8"
            $primaryUrl = if ($networkMode -and $primaryIp -ne "localhost") { "http://${primaryIp}:${port}/" } else { "http://localhost:${port}/" }
            $infoObj = @{
                port = $port
                primaryIp = $primaryIp
                serverUrl = $primaryUrl
                networkMode = $networkMode
                ipList = @($ipList)
            }
            $jsonStr = ConvertTo-Json $infoObj
            $infoBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonStr)
            $response.OutputStream.Write($infoBytes, 0, $infoBytes.Length)
            $response.Close()
            continue
        }

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
