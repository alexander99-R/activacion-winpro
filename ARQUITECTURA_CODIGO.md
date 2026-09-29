# 💻 Arquitectura y Documentación del Código — Activación WinPro

Este documento detalla la estructura del código fuente, explicando **qué hace cada apartado**, cómo interactúan sus componentes y dónde se ubica cada función dentro del proyecto.

---

## 📁 1. Estructura de Archivos del Proyecto

```text
MACROTEC/
├── index.html              <-- Aplicación principal completa (Estilos, HTML y JavaScript)
├── server.ps1              <-- Servidor HTTP en PowerShell nativo para red local y sync
├── iniciar-servidor.bat    <-- Script de inicio rápido de un solo clic para Windows
├── jsbarcode.min.js        <-- Librería local para renderizar códigos de barras CODE128
├── logo-black.png          <-- Logo Sharkoon para Modo Claro
├── logo-white.png          <-- Logo Sharkoon para Modo Oscuro
├── verify.ps1              <-- Script de pruebas y verificación de integridad
├── subir-github.bat        <-- Script automatizado para commits y push a GitHub
├── MANUAL_USUARIO.md       <-- Manual operativo para el personal del taller
├── FUNCIONAMIENTO_SISTEMA.md<-- Explicación de la arquitectura y flujo de datos
└── ARQUITECTURA_CODIGO.md  <-- Este documento (análisis detallado del código)
```

---

## 🎨 2. Desglose de `index.html` — Capa de Estilos (CSS)
*Ubicación: Líneas 14 a 2575*

### 2.1. Tokens de Diseño y Variables CSS (`:root` y `[data-theme="dark"]`)
- **Modo Claro (`:root`):**
  - `--navy: #0B2A4A`: Azul corporativo para títulos y elementos de peso.
  - `--blue: #5FB9E4`: Celeste Sharkoon para botones de acción y destaques.
  - `--surface: #FFFFFF`: Fondo de tarjetas limpias.
  - `--bg: #F4F7FB`: Fondo neutro suave.
- **Modo Oscuro (`[data-theme="dark"]`):**
  - `--bg: #000000`: Fondo negro OLED absoluto solicitado por el taller.
  - `--surface: #0E0E10` y `--surface-card: #141416`: Fondos neutros oscuros sin tintes azules antiguos.
  - `--text: #FFFFFF` y `--text-muted: #A1A1AA`: Contraste de texto calibrado para evitar fatiga visual.

### 2.2. Sistema de Iluminación Hover (*Glow Effect*)
Configurado en las clases `.icon`, `.btn-icon` y botones:
```css
[data-theme="dark"] .icon:hover,
[data-theme="dark"] .btn-icon:hover .icon {
  filter: drop-shadow(0 0 5px #FFFFFF) drop-shadow(0 0 12px rgba(95, 185, 228, 0.9));
  transform: scale(1.12);
}
```
Genera un halo de luz reactivo cuando el usuario pasa el mouse por encima de cualquier botón interactivo.

### 2.3. Animación Cinemática del Tiburón (*Shark Glide-In*)
- `@keyframes sharkGlideIn`: Controla el deslizamiento hidrodinámico del tiburón al abrir el Login, con ondulación de ángulo (`-5deg` a `+2.5deg`) y desaceleración en 0.85s.
- `@keyframes titleShimmer`: Genera el destello luminoso sobre las letras de "Activacion WinPro" cuando el tiburón se asienta.
- `@keyframes badgePulse`: Pulso de expansión sobre la insignia "WINDOWS 11 PRO".

### 2.4. Estilos de Impresión Físicos (`@media print`)
- Oculta la barra de navegación, botones y tarjetas.
- Ajusta el tamaño de la etiqueta adhesiva a dimensiones estándar de impresión térmica para códigos de barras `WIN****`.

---

## 🧱 3. Desglose de `index.html` — Estructura (HTML)
*Ubicación: Líneas 2580 a 3770*

### 3.1. Vista 1: Pantalla de Login (`#view-login`)
- `#btn-login-admin`: Botón de acceso directo para el Administrador con icono de candado.
- `#login-users-list`: Contenedor dinámico que renderiza los avatares y nombres de los técnicos disponibles.
- `#login-lockout-msg`: Banner de advertencia que se muestra solo si el sistema se bloquea por 5 intentos fallidos.
- `#btn-theme-login`: Interruptor para alternar Modo Claro / Oscuro desde el login.

### 3.2. Vista 2: Panel de Aplicación (`#app-container`)
- **Header Superior (`.top-header`):** Contiene el logo reactivo, el nombre de la app, estado del técnico y el menú de perfil (tuerquita ⚙️).
- **Barra de Pestañas Desktop y Móvil:**
  - `tab-licencias`: Panel central de inventario.
  - `tab-garantia`: Panel de redacción de reportes para WhatsApp.
  - `tab-stats`: Gráficos de barras y consumo mensual.
  - `tab-auditoria`: Tabla de historial completo de instalaciones.

### 3.3. Ventanas Modales (Diálogos Flotantes)
- `#modal-pin`: Teclado numérico en pantalla para validar accesos.
- `#modal-install`: Formulario obligatorio de instalación (Orden SO, Equipo o Cliente).
- `#modal-missing-fields`: Advertencia cuando un técnico no ingresó ningún dato identificador.
- `#modal-add-license`: Formulario de alta individual de clave.
- `#modal-import-batch`: Cuadro de importación masiva inteligente con previsualización.
- `#modal-user-manage`: Gestor de técnicos (alta, baja, cambio de PIN y foto).
- `#modal-qr-connect`: Despliegue del código QR para vincular teléfonos por Wi-Fi.
- `#modal-session-timeout`: Contador regresivo de 60 segundos por inactividad.

---

## ⚡ 4. Desglose de `index.html` — Lógica JavaScript
*Ubicación: Líneas 3775 a 8124*

La lógica está organizada en **módulos bien delimitados**:

### 📦 Módulo 1: Estado Global (`State`) y Persistencia
- **Objeto `State`:** Centraliza en memoria `licenses`, `users`, `activityLogs`, `currentRole`, `currentUser` y `selectedLicenseIds`.
- **`loadInitialState()`:** Lee `localStorage` (o carga valores de fábrica si es la primera ejecución).
- **`saveStateToStorage()`:** Serializa el estado en JSON y lo guarda simultáneamente en las claves locales y despacha actualización a `/api/sync` si hay servidor activo.

### 🔐 Módulo 2: Seguridad, Sesiones y Temporizadores
- **`loginUser(user, role)`:** Inicializa la sesión, oculta el login, muestra el app container y arranca los temporizadores.
- **`logoutUser()`:** Limpia las credenciales activas, resetea la animación del tiburón y devuelve al usuario a la pantalla de selección.
- **`checkPin(enteredPin)`:** Valida el PIN contra el usuario seleccionado y gestiona el contador de intentos fallidos.
- **`resetSessionInactivityTimer()`:** Monitorea la inactividad; si pasan 14 minutos sin movimiento, lanza la advertencia de timeout.

### 📋 Módulo 3: Gestión de Licencias e Instalaciones
- **`addLicense(keyData)`:** Asigna el código secuencial `WIN****` más bajo disponible y registra la clave.
- **`importBatchLicenses(textBlock)`:** Expresión regular `[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}` que extrae claves de textos desordenados, descarta duplicadas y valida formato.
- **`confirmInstallLicense(id, data)`:** Valida que al menos uno de los tres campos (Orden, Equipo o Cliente) no esté vacío, cambia el estado a `"Instalada"`, guarda el nombre del técnico y fecha y genera el log de auditoría.

### 🎛️ Módulo 4: Renderizado de Interfaz
- **`renderLicensesTable()`:** Construye las tarjetas de licencia. En el modo técnico, aplica ordenamiento FIFO estricto (códigos WIN más bajos primero).
- **`copyActivationCommand(key)`:** Copia al portapapeles `slmgr -ipk [CLAVE]` y emite un Toast visual de confirmación sin cuadros de alerta invasivos.

### 📊 Módulo 5: Gráficos Vectoriales Puros (SVG)
- **`renderStatsCharts()`:** Sin necesidad de librerías pesadas como Chart.js, genera elementos `<svg>`, `<rect>`, `<polyline>` y `<circle>` en tiempo real:
  - Distribución por estado (Disponible en celeste, Instalada en verde, Probar en amarillo `#FACC15`, Dañada en rojo).
  - Línea de tendencia mensual con puntos interactivos.

### 📜 Módulo 6: Auditoría y Código de Barras
- **`renderActivityLogsTable()`:** Muestra la lista de movimientos con badges estilizados y colores de alto contraste (`.audit-log-user`, `.audit-log-order`).
- **`printWinCodeSticker(winCode)`:** Crea la etiqueta en un canvas invisible usando `JsBarcode`, inyecta los datos y dispara la ventana nativa de impresión de Windows.

### 👥 Módulo 7: Gestión de Usuarios
- Permite crear perfiles para cada técnico del taller, asignar avatar o foto cuadrada, definir PIN individual y restringir permisos.

### 💾 Módulo 8: Backup y Restauración JSON
- **`downloadBackupJson()`:** Empaqueta todo el estado del sistema en un archivo `.json` con fecha y hora para resguardo fuera de línea.
- **`restoreBackupJson(file)`:** Lee el archivo, valida su estructura interna y reconstruye el inventario completo al instante.

---

## 🔌 5. Servidor de Red Local (`server.ps1`)

Script escrito en PowerShell nativo de Windows:
1. **Instancia de `System.Net.HttpListener`:** Escucha peticiones en el puerto `8080`.
2. **Detección Automática de IP:** Lee la tarjeta de red activa (`Get-NetIPAddress`) para mostrar la URL exacta que deben ingresar los técnicos en sus teléfonos (ej. `http://192.168.1.45:8080`).
3. **Servicio de Archivos Estáticos:** Responde a peticiones GET de `index.html`, imágenes PNG y librerías JS con las cabeceras MIME correspondientes.
4. **Endpoint REST `/api/sync`:**
   - **GET:** Retorna el último archivo `database.json`.
   - **POST:** Recibe las actualizaciones de los clientes y las escribe de forma atómica en el disco duro.

---

## 🧪 6. Script de Validación Estricta (`verify.ps1`)

Herramienta de aseguramiento de calidad (QA):
- Escanea el archivo `index.html` para garantizar:
  1. **Cero atributos con base64 en `onclick`** (previene fallos de seguridad y cuelgues del navegador).
  2. **Cero diálogos nativos bloqueantes** (`alert()`, `confirm()`, `prompt()`), verificando que solo se usen modales y Toasts estilizados.
  3. **Comando `slmgr -ipk` presente e íntegro.**
  4. **Capa dual de persistencia presente.**
