# 📘 Manual de Usuario — Sistema Activación WinPro (Windows 11 Pro)

Bienvenido al manual oficial de usuario de **Activación WinPro**, la plataforma diseñada específicamente para el control, instalación y auditoría de licencias en talleres de servicio técnico y ensamble.

---

## 📑 Tabla de Contenidos
1. [Introducción y Requisitos](#1-introducción-y-requisitos)
2. [Roles de Acceso y Pantalla de Inicio (Login)](#2-roles-de-acceso-y-pantalla-de-inicio-login)
3. [Guía para Técnicos (Uso Diario)](#3-guía-para-técnicos-uso-diario)
   - [Instalación de una Licencia](#instalación-de-una-licencia)
   - [Copiar Comando de Activación Directo](#copiar-comando-de-activación-directo)
   - [Marcar como "Probar otra vez" o "Dañada"](#marcar-como-probar-otra-vez-o-dañada)
4. [Guía para Administradores](#4-guía-para-administradores)
   - [Gestión de Licencias e Importación Masiva](#gestión-de-licencias-e-importación-masiva)
   - [Ordenamiento y Filtrado de Códigos WIN](#ordenamiento-y-filtrado-de-códigos-win)
   - [Garantías y Reportes para WhatsApp](#garantías-y-reportes-para-whatsapp)
   - [Panel de Estadísticas y Gráficos](#panel-de-estadísticas-y-gráficos)
   - [Auditoría, Historial e Impresión de Etiquetas](#auditoría-historial-e-impresión-de-etiquetas)
   - [Gestión de Usuarios y PINs](#gestión-de-usuarios-y-pins)
   - [Copias de Seguridad y Restauración](#copias-de-seguridad-y-restauración)
5. [Seguridad y Temporizadores Automáticos](#5-seguridad-y-temporizadores-automáticos)
6. [Preguntas Frecuentes y Solución de Problemas](#6-preguntas-frecuentes-y-solución-de-problemas)

---

## 1. Introducción y Requisitos

**Activación WinPro** funciona de forma 100% autónoma en cualquier navegador web moderno (Google Chrome, Microsoft Edge, Mozilla Firefox o Safari). 
- No requiere instalar bases de datos externas como MySQL o SQL Server.
- Puede ejecutarse abriendo el archivo `index.html` de forma local o a través de la red del taller ejecutando `iniciar-servidor.bat`.
- Cuenta con modo claro y modo oscuro de alto contraste con iconos iluminados.

---

## 2. Roles de Acceso y Pantalla de Inicio (Login)

Al abrir la aplicación, el logotipo animado del tiburón nadará hacia el centro y verás la pantalla de acceso:

### 🛡️ Rol Administrador
- **Acceso:** Haz clic en la tarjeta superior **"Administrador — Control total del inventario"**.
- **Seguridad:** Solicita un PIN numérico de 4 a 6 dígitos (PIN predeterminado: `1234`).
- **Permisos:** Control total. Puede agregar/eliminar licencias, cambiar estados, gestionar usuarios, generar reportes de garantía, ver estadísticas financieras y descargar/cargar copias de seguridad.

### 👨‍🔧 Rol Técnico
- **Acceso:** Haz clic sobre tu nombre o fotografía en la cuadrícula de técnicos.
- **Seguridad:** Ingresa tu PIN personal asignado.
- **Permisos:** Enfocado únicamente en el trabajo de banco de taller. El técnico puede:
  - Ver las licencias disponibles ordenadas cronológicamente (las de código WIN más bajo primero).
  - Copiar comandos de activación `slmgr -ipk`.
  - Instalar licencias registrando la Orden SO, el Equipo o el Cliente.
  - Reportar licencias para reintento (*Probar*) o dañadas.
  - *Restricciones:* No ve opciones de copias de seguridad, no puede borrar registros de auditoría ni alterar usuarios.

---

## 3. Guía para Técnicos (Uso Diario)

### Instalación de una Licencia
1. En la lista principal de licencias, localiza la primera disponible (el sistema siempre te mostrará al inicio la licencia con el código `WIN****` más antiguo/bajo).
2. Haz clic en el botón verde **"Instalada"**.
3. Aparecerá la ventana modal de validación:
   - **Orden de Servicio (SO):** Número de ticket u orden de taller (ej. `SO-4091`).
   - **Equipo:** Modelo o características del equipo (ej. `Laptop Dell Inspiron 15`).
   - **Cliente:** Nombre del propietario (ej. `Juan Pérez`).
   > *Regla de validación:* Es obligatorio ingresar **al menos uno de los tres campos** para evitar licencias "huérfanas" sin trazabilidad.
4. Presiona **"Confirmar Instalación"**. La licencia cambiará automáticamente a estado "Instalada" y quedará registrada bajo tu nombre y fecha exacta.

### Copiar Comando de Activación Directo
- En la tarjeta de la licencia, haz clic en el botón **"Copiar Comando"**.
- El sistema copiará al portapapeles de Windows la instrucción oficial:
  ```cmd
  slmgr -ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
  ```
- En la máquina del cliente, solo abres la consola de comandos (`cmd.exe`) o PowerShell como Administrador, pegas con `Ctrl + V` y presionas `Enter`.

### Marcar como "Probar otra vez" o "Dañada"
- **Probar otra vez (Amarillo):** Si el servidor de Microsoft no respondió en ese momento o hubo un corte de internet, márcala como *Probar*. Esto le indica a los demás técnicos que la clave debe ser reintentada antes de desecharse.
- **Dañada (Rojo):** Si la clave fue bloqueada por Microsoft o superó el límite de activaciones, márcala como *Dañada*. Te solicitará una breve nota de motivo para que el Administrador pueda tramitar la garantía con el proveedor.

---

## 4. Guía para Administradores

El Administrador tiene una barra de navegación superior con 4 pestañas especializadas:

### 1. Pestaña "Licencias"
- **Carga Individual:** Botón **"+ Nueva Licencia"** para agregar claves manuales.
- **Importación Masiva Inteligente:** Botón **"Importar Lote"**. Puedes pegar listas completas de texto o correos de proveedores. El sistema detecta automáticamente cualquier clave en formato `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`, descarta duplicadas y valida que tengan 25 caracteres alfanuméricos.
- **Selección Múltiple:** Puedes marcar casillas para cambiar de estado lotes de 10, 20 o 50 licencias a la vez o eliminarlas.
- **Exportar a Excel (CSV):** Descarga el inventario filtrado por mes o completo con codificación UTF-8 compatible con Microsoft Excel.

### 2. Pestaña "Garantía" (Reportes WhatsApp)
- Diseñado para cuando compraste un paquete de licencias y algunas salieron defectuosas.
- Filtra por proveedor o fecha.
- El sistema genera un **mensaje redactado profesionalmente para WhatsApp** con el listado exacto de claves fallidas, fechas y motivos de error.
- Incluye botón directo **"Copiar Reporte"** o **"Enviar por WhatsApp"**.

### 3. Pestaña "Estadísticas"
- **Tarjetas KPI:** Total de licencias en inventario, disponibles, instaladas, en prueba y dañadas.
- **Gráficos Vectoriales Puros:**
  - Gráfico de barras de distribución por estados.
  - Gráfico de línea de tiempo con altas y consumos mensuales.
- **Filtro Mensual:** Permite auditar cuántas licencias se gastaron en cada mes del año.

### 4. Pestaña "Auditoría e Historial"
- Registro inmutable de cada acción realizada en el sistema (quién instaló, a qué hora, qué cliente y qué orden).
- **Impresión de Etiquetas Físicas:** Al lado de cada instalación hay un botón con icono de impresora. Genera una etiqueta adhesiva con el código de barras `WIN****` (usando JsBarcode) lista para imprimir y pegar en el chasis del CPU o la laptop del cliente.

### Gestión de Usuarios y PINs
- En la esquina superior derecha, haz clic en el icono de tuerca ⚙️ y elige **"Administrar Usuarios"**.
- Puedes agregar técnicos nuevos, cambiarles el PIN, subir su foto de perfil y suspender o reactivar accesos.

### Copias de Seguridad y Restauración
- En la tuerca ⚙️ de ajustes, selecciona **"Descargar Copia de Seguridad"**.
- Se descargará un archivo `.json` con todas las licencias, técnicos, historial y configuraciones.
- Para restaurar en otra máquina o tras formatear, usa **"Cargar Respaldo"** y selecciona el archivo `.json`.

---

## 5. Seguridad y Temporizadores Automáticos

1. **Bloqueo por Fuerza Bruta:** Si alguien ingresa un PIN incorrecto 5 veces consecutivas, el sistema bloquea el acceso durante 30 segundos con un contador regresivo visible.
2. **Cierre Automático por Inactividad:** Si el sistema queda desatendido durante 15 minutos sin interacción del ratón o teclado, muestra una alerta regresiva de 60 segundos. Si nadie responde, cierra la sesión automáticamente para proteger la información del taller.

---

## 6. Preguntas Frecuentes y Solución de Problemas

* **¿Por qué los técnicos ven las licencias en un orden específico?**
  El sistema muestra por defecto las licencias con el código `WIN****` más bajo primero para asegurar que se utilicen las licencias más antiguas antes que las recién compradas (sistema FIFO: primero en entrar, primero en salir).
* **¿Qué hago si se borra el historial del navegador?**
  Si ejecutaste el servidor local (`iniciar-servidor.bat`), los datos también están respaldados. Si trabajas offline, solo debes ir a la tuerca de ajustes como Administrador y cargar el último archivo `.json` de respaldo.
* **¿Cómo cambio entre modo claro y modo oscuro?**
  En la esquina inferior del Login o en el menú de usuario dentro del sistema hay un botón con icono de sol/luna. En modo oscuro, los iconos y logotipos brillan suavemente para facilitar la lectura en entornos con poca luz.
