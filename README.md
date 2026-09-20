# 🧠 MACROTEC — Sistema de Inventario de Licencias Windows 11 Pro
**Versión Multi-Agente 2.1 | El Salvador**

Sistema web autónomo, reactivo y moderno desarrollado en **Vanilla HTML5 + CSS3 + JavaScript**, optimizado tanto para ejecución como **Artefacto de Claude AI con capacidad `db`** (`claude.use("db")`) como para funcionamiento local / offline con persistencia en `localStorage`.

---

## 🚀 Características del Sistema

### 👨‍🔧 1. Vista Enfocada para Técnicos
- **Sin barra de búsqueda ni filtros complejos**: La interfaz del técnico es limpia y directa. Se eliminaron los selectores de fechas y ordenamientos para maximizar la velocidad de trabajo.
- **Resumen Numérico de Instaladas y Dañadas**:
  - En la parte superior de la vista de técnicos se muestra un banner métrico con tres tarjetas:
    - **Disponibles**: Total de licencias listas para instalación.
    - **Instaladas**: Cantidad total registrada (los técnicos solo visualizan el número, no las claves ya instaladas).
    - **Dañadas**: Cantidad total en garantía (los técnicos solo visualizan el número).
- **Operación Rápida**: El técnico visualiza únicamente las licencias **Disponibles** (o en **Probar otra vez**) con el botón destacado **"Copiar CMD"** para ejecutar en Windows:
  ```cmd
  slmgr -ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
  ```
  y los botones de un solo toque para marcar como **Instalada**, **Probar** o **Dañada**.

---

### 🛡️ 2. Panel de Administración y Control
- **Exclusividad de Reportes y Búsqueda**: Solo el Administrador puede buscar por texto, ver el historial completo de claves instaladas, ver auditorías y emitir reportes.
- **Reportes Generales Formales (Sin Emoticones)**:
  - Formato sobrio y profesional para compartir por WhatsApp sin emojis ni elementos informales.
- **Módulo de Reporte a Proveedor (Licencias Dañadas) con Borrado**:
  - Ubicado en la pestaña de Administración y con acceso directo desde el banner de alerta de licencias dañadas.
  - Consolida automáticamente todas las claves dañadas en un reporte listo para enviar al proveedor por WhatsApp o copiar al portapapeles.
  - **Borrado Preventivo**: Incluye la opción de eliminar las claves dañadas reportadas con confirmación segura para no volver a enviarlas en futuros reportes.
- **Compartir Enlace de Acceso**:
  - Tarjeta en la pestaña de Administración que muestra la URL activa del sistema con botones para **"Copiar Enlace"** y **"Compartir por WhatsApp"** con instrucciones claras para los técnicos.

---

### ⚙️ 3. Importador Inteligente & Estadísticas
- **Importador por Lotes**: Detecta claves Windows en formato 5x5 (`XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`) en cualquier texto pegado, descartando duplicados con previsualización.
- **Estadísticas con Gráficos SVG Puros**: Gráfico de barras por estado, gráfico de línea temporal de altas y podio Top 3 de técnicos más activos.
- **Exportación CSV**: Descarga instantánea de inventario instalado y registros de auditoría.

---

### 🔒 4. Seguridad, PIN y Sesiones
- **PIN de 4 dígitos** (inicial `3210`, con retrocompatibilidad para `321`).
- **Protección contra fuerza bruta**: Bloqueo temporal por 30 segundos tras 3 intentos fallidos.
- **Cierre por inactividad**: Sesión activa por 30 minutos con aviso previo a los 28 minutos.
- **Cero funciones nativas invasivas**: Todos los avisos y confirmaciones usan modales personalizados.

---

## 🛠️ Guía de Mantenimiento, Ejecución y Alojamiento 24/7

### 📁 1. ¿Dónde está almacenado el código?
El código completo del sistema reside en un **único archivo autosuficiente**:
```text
C:\Users\alexa\.gemini\antigravity\scratch\macrotec\index.html
```
- Contiene todo el **CSS**, **HTML** y **JavaScript** en un solo archivo de ~4,300 líneas, sin dependencias de Node.js, sin `npm`, y sin necesidad de procesos de compilación o empaquetado.

### ✏️ 2. ¿Cómo darle mantenimiento?
1. Abre el archivo `index.html` con cualquier editor de texto o código (recomendado: **Visual Studio Code**, Notepad++, o Sublime Text).
2. El código está organizado en secciones claramente comentadas:
   - `<style>`: Diseño visual, variables y temas (Líneas 10–1470).
   - `<body>`: Vistas HTML, navegación, paneles y modales (Líneas 1475–2160).
   - `<script>`:
     - `DB_SERVICE`: Capa de datos (Firestore / LocalStorage).
     - `State`: Variables de estado reactivas.
     - Funciones de autenticación, licencias, reportes y eventos.
3. Para validar que ningún cambio rompa las reglas de seguridad, puedes ejecutar en cualquier momento:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\Users\alexa\.gemini\antigravity\scratch\macrotec\verify.ps1"
   ```

### 💻 3. ¿Dónde y cómo correrlo en tu computadora?
- **Opción A (Servidor Local PowerShell ya activo)**:
  El script `server.ps1` corre en segundo plano escuchando en:
  👉 **http://localhost:8080/**
- **Opción B (Directo en navegador)**:
  Puedes hacer doble clic en `index.html` o arrastrarlo a Chrome/Edge/Firefox. Funciona inmediatamente con `localStorage`.
- **Opción C (Extensión Live Server en VS Code)**:
  Click derecho en `index.html` > *Open with Live Server*.

---

### 🌐 4. ¿Dónde alojarlo para que NUNCA se caiga (24/7, gratis o bajo costo)?

Para que el sistema esté disponible permanentemente desde cualquier celular o PC sin depender de que tu computadora personal esté encendida:

#### ⭐ Opción Recomendada 1: Firebase Hosting (Google Cloud) — 100% Gratis y Ultra Estable
- **Disponibilidad**: 99.95% en la red CDN mundial de Google.
- **Costo**: $0 (Plan Spark gratuito incluye 10 GB de almacenamiento y 360 MB/día de transferencia, más que suficiente para miles de visitas).
- **Pasos para publicar**:
  1. Instala Firebase CLI: `npm install -g firebase-tools`
  2. Inicia sesión: `firebase login`
  3. En la carpeta del proyecto, ejecuta: `firebase init hosting` (selecciona tu proyecto de Google Cloud / Firebase y usa la carpeta actual).
  4. Despliega: `firebase deploy --only hosting`
  5. Te entregará una URL permanente con certificado SSL gratuito (ejemplo: `https://macrotec-inventario.web.app`).

#### ⭐ Opción Recomendada 2: GitHub Pages — 100% Gratis y Seguro
- **Disponibilidad**: Respaldado por los servidores de Microsoft / GitHub.
- **Costo**: $0 de por vida.
- **Pasos**:
  1. Crea un repositorio en GitHub (ej. `macrotec-sistema`).
  2. Sube el archivo `index.html`.
  3. En GitHub ve a *Settings > Pages > Branch: main > Save*.
  4. Tu sistema estará en línea en `https://tu-usuario.github.io/macrotec-sistema/`.

#### ⭐ Opción Recomendada 3: Vercel / Netlify / Cloudflare Pages
- Arrastras el archivo `index.html` a su panel web y en 10 segundos tienes un enlace HTTPS global que nunca se cae.

---

### 🔄 5. Persistencia de la Base de Datos para Múltiples Dispositivos
- **En Claude AI**: El sistema utiliza automáticamente `claude.use("db")` (Firestore gestionado por Claude).
- **En Navegador Normal / Hosting Web**: El sistema usa `localStorage` para guardar datos en el dispositivo actual. Si requieres que múltiples técnicos sincronizados desde diferentes teléfonos modifiquen el mismo inventario en tiempo real desde la nube, puedes conectar las funciones de `DB_SERVICE` a una instancia gratuita de **Firebase Cloud Firestore** (hasta 50,000 lecturas y 20,000 escrituras diarias gratis).

---

## 📋 Credenciales Iniciales
- **Administrador**: PIN `3210` (o `321`)
- **Técnicos de Prueba**: PIN `3210` (o `321`)
  - Juan Pérez (Técnico)
  - Carlos Gómez (Técnico)
  - Ana Morales (Visor)
