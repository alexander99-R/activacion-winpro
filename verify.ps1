$targetPath = if (Test-Path ".\index.html") { ".\index.html" } else { "C:\Users\alexa\.gemini\antigravity\scratch\macrotec\index.html" }
$lines = Get-Content -Path $targetPath
$totalLines = $lines.Count

Write-Host "=== VERIFICACIÓN ESTRICTA SISTEMA ACTIVACION WINPRO ==="
Write-Host "Total de líneas:" $totalLines

$b64InOnclick = 0
$nativeConfirmCalls = 0
$nativeAlertCalls = 0
$nativePromptCalls = 0
$slmgrMatches = 0
$win11Matches = 0
$dualDbMatches = 0

for ($i = 0; $i -lt $totalLines; $i++) {
    $line = $lines[$i]

    # Verificar si hay onclick con base64
    if ($line -match 'onclick' -and $line -match 'base64') {
        $b64InOnclick++
        Write-Host "Línea $($i+1): $line"
    }

    # Verificar llamadas a confirm(), alert(), prompt() en JavaScript
    if ($line -notmatch '^\s*//' -and $line -notmatch '<!--') {
        if ($line -match '\bconfirm\s*\(') {
            $nativeConfirmCalls++
            Write-Host "Línea $($i+1) confirm: $line"
        }
        if ($line -match '\balert\s*\(') {
            $nativeAlertCalls++
            Write-Host "Línea $($i+1) alert: $line"
        }
        if ($line -match '\bprompt\s*\(') {
            $nativePromptCalls++
            Write-Host "Línea $($i+1) prompt: $line"
        }
    }

    if ($line -match 'slmgr -ipk') { $slmgrMatches++ }
    if ($line -match 'Windows 11 Pro') { $win11Matches++ }
    if ($line -match 'claude\.use|winpro_db') { $dualDbMatches++ }
}

Write-Host "1. Ocurrencias de Base64 en onclick: $b64InOnclick (Esperado: 0)"
Write-Host "2. Llamadas a confirm() nativo: $nativeConfirmCalls (Esperado: 0)"
Write-Host "3. Llamadas a alert() nativo: $nativeAlertCalls (Esperado: 0)"
Write-Host "4. Llamadas a prompt() nativo: $nativePromptCalls (Esperado: 0)"
Write-Host "5. Comando slmgr -ipk presente: $slmgrMatches (Esperado: >0)"
Write-Host "6. Mención Windows 11 Pro: $win11Matches (Esperado: >0)"
Write-Host "7. Capa dual DB / Local: $dualDbMatches (Esperado: >0)"

if ($b64InOnclick -eq 0 -and $nativeConfirmCalls -eq 0 -and $nativeAlertCalls -eq 0 -and $nativePromptCalls -eq 0 -and $slmgrMatches -gt 0 -and $win11Matches -gt 0 -and $dualDbMatches -gt 0) {
    Write-Host "`n>>> RESULTADO: 100% APROBADO SIN ERRORES NI RIESGOS <<<" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n>>> RESULTADO: FALLO EN VALIDACIÓN <<<" -ForegroundColor Red
    exit 1
}
