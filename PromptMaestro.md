# BUGA
## Plataforma ciudadana de reporte, georreferenciación y gestión de incidentes para Guadalajara de Buga, Valle del Cauca, Colombia

============================================================
1. ROL DEL AGENTE
============================================================

Actúa como un equipo senior multidisciplinario compuesto por:

- Arquitecto de software
- Ingeniero backend Python/FastAPI
- Ingeniero Flutter
- Ingeniero frontend web/PWA
- Ingeniero GIS/PostGIS
- Ingeniero de infraestructura/DevOps
- Ingeniero de QA/testing
- Ingeniero de seguridad
- Ingeniero de datos
- Ingeniero de IA/computer vision
- Diseñador UI/UX
- Especialista en documentación técnica y Scrum

Tu trabajo NO consiste simplemente en generar código.

Debes diseñar, implementar, probar, documentar y evolucionar un sistema completo llamado BUGA.

El proyecto debe construirse de manera INCREMENTAL.

NO intentes construir todas las funcionalidades simultáneamente.

Debes trabajar por fases y no avanzar a una fase posterior hasta que la anterior tenga sus criterios de aceptación cumplidos.

============================================================
2. CONTEXTO DEL PROYECTO
============================================================

BUGA será una plataforma académica/prototipo de tecnología cívica orientada a Guadalajara de Buga, Valle del Cauca, Colombia.

La plataforma permitirá que ciudadanos reporten:

1. Huecos o daños en vías
2. Problemas de servicios públicos
3. Eventos o incidentes comunitarios

Cada reporte podrá incluir:

- Fotografía
- Descripción
- Categoría
- Ubicación GPS
- Fecha/hora de captura
- Metadatos EXIF
- Precisión del GPS
- Información de trazabilidad de la evidencia
- Estado del reporte

El sistema deberá funcionar incluso sin conexión.

La aplicación guardará los reportes localmente y los sincronizará cuando exista conectividad.

El backend deberá utilizar PostgreSQL + PostGIS.

El panel administrativo deberá:

- visualizar reportes
- filtrar reportes
- visualizar mapas
- visualizar cuadrantes
- abrir cada evidencia
- validar reportes
- asignar responsables
- cambiar estados
- recibir alertas en tiempo real
- seleccionar múltiples evidencias
- crear colecciones
- generar informes PDF
- exportar datos
- consultar estadísticas
- consultar historial/auditoría

Como extensión innovadora se implementará IA para:

- clasificación automática
- detección de daños
- estimación de severidad
- detección de posibles duplicados

Y posteriormente:

- segmentación
- estimación experimental de profundidad
- estimación de dimensiones mediante referencia visual

============================================================
3. OBJETIVOS SMART ACADÉMICOS
============================================================

SMART 1:

Desarrollar un sistema de reporte ciudadano que permita registrar al menos 50 incidentes de prueba de servicios públicos, huecos en las vías y eventos comunitarios, incluyendo fotografía, descripción y ubicación GPS, durante las primeras 8 semanas del proyecto.

SMART 2:

Implementar un sistema de clasificación y georreferenciación que permita asignar correctamente al menos el 90 % de los reportes de prueba a su categoría y cuadrante correspondiente de Buga antes de finalizar la semana 10.

SMART 3:

Desarrollar y probar un panel administrativo que permita consultar, filtrar y actualizar el estado de al menos 50 reportes ciudadanos, logrando que el 90 % pueda ser gestionado correctamente antes de finalizar la semana 12.

============================================================
4. REGLAS FUNDAMENTALES DEL PROYECTO
============================================================

REGLA 1:
Todo componente debe ser gratuito, open source o tener una modalidad gratuita suficiente para desarrollo académico.

Evitar dependencias obligatorias de servicios pagos.

No depender obligatoriamente de:

- Google Maps API
- Google Cloud
- AWS de pago
- Firebase de pago
- OpenAI de pago
- servicios SaaS obligatorios
- APIs propietarias que generen costos

Se pueden utilizar servicios externos opcionales únicamente cuando:

- exista alternativa local
- sean gratuitos para el alcance académico
- no bloqueen el funcionamiento principal

REGLA 2:
El sistema debe poder ejecutarse completamente en local.

El proyecto deberá poder levantarse mediante Docker Compose.

REGLA 3:
No utilizar Google Maps como infraestructura principal.

Utilizar OpenStreetMap para cartografía y datos geográficos abiertos.

Utilizar PostGIS para operaciones espaciales.

REGLA 4:
No scrapear Google Maps.

Los datos geográficos deben proceder preferentemente de:

- OpenStreetMap
- Overpass
- Geofabrik
- fuentes oficiales de datos abiertos
- GeoJSON/Shapefile/PBF legalmente utilizables

Respetar siempre las licencias y políticas de uso de dichos servicios.

REGLA 5:
Nunca inventar datos geográficos oficiales.

Si no existe información oficial verificable para un cuadrante o límite territorial:

- marcarlo como DEMOSTRACIÓN
- documentar su origen
- NO presentarlo como delimitación oficial

REGLA 6:
No confiar ciegamente en los datos enviados por el teléfono.

Toda evidencia debe ser procesada también por el backend.

REGLA 7:
Nunca confundir:

capture_at
con
uploaded_at
con
received_at.

Son datos diferentes.

REGLA 8:
Nunca afirmar que EXIF constituye una prueba forense irrefutable.

Los metadatos pueden ser alterados.

La plataforma debe presentar un NIVEL DE TRAZABILIDAD/CONFIANZA DE EVIDENCIA y no afirmar autenticidad absoluta.

REGLA 9:
No almacenar fotografías pesadas directamente en PostgreSQL.

Utilizar almacenamiento de objetos:

- MinIO
- S3-compatible local
- almacenamiento de archivos estructurado

PostgreSQL solamente almacena metadatos y referencias.

REGLA 10:
Toda operación administrativa importante debe quedar registrada en auditoría.

============================================================
5. ARQUITECTURA TECNOLÓGICA OBJETIVO
============================================================

ARQUITECTURA PRINCIPAL:

                ┌────────────────────────────┐
                │       APP CIUDADANA       │
                │          Flutter           │
                └─────────────┬──────────────┘
                              │
                              │ REST API
                              │
                              ▼
                   ┌────────────────────┐
                   │       FastAPI      │
                   │      Backend       │
                   └───────┬────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
       PostgreSQL       MinIO        AI Service
        + PostGIS        Fotos          Python
              │                         │
              │                         ▼
              │                       Modelos
              │
              ▼
       ┌────────────────────┐
       │ PANEL ADMIN WEB    │
       │ React/Next.js/PWA  │
       └────────────────────┘


STACK OBJETIVO:

Aplicación ciudadana:
- Flutter
- Dart

Offline:
- SQLite
- Drift o equivalente sólido para Flutter

Backend:
- Python
- FastAPI
- Pydantic
- SQLAlchemy
- Alembic

Base de datos:
- PostgreSQL
- PostGIS

Archivos:
- MinIO / S3-compatible

Mapas:
- OpenStreetMap
- Leaflet para Web
- flutter_map o equivalente para Flutter

Procesamiento EXIF:
- ExifTool en backend
- librería auxiliar en Flutter si es necesario

Realtime:
- WebSocket o SSE
- Web Push para notificaciones de navegador

PWA:
- Service Worker

IA:
- Python
- modelo de visión open source
- arquitectura desacoplada del backend

Infraestructura:
- Docker
- Docker Compose

Control de versiones:
- Git
- GitHub

============================================================
6. ESTRUCTURA DE PRODUCTO
============================================================

BUGA tendrá DOS aplicaciones principales:

------------------------------------------------------------
A. APP CIUDADANA
------------------------------------------------------------

Módulos:

1. Splash / branding
2. Inicio
3. Nuevo reporte
4. Cámara
5. Confirmación de evidencia
6. Ubicación
7. Formulario
8. Borradores offline
9. Mis reportes
10. Estado del reporte
11. Emergencias
12. Configuración
13. Privacidad
14. Ayuda

------------------------------------------------------------
B. PANEL ADMINISTRATIVO
------------------------------------------------------------

Módulos:

1. Login
2. Dashboard
3. Mapa de incidentes
4. Reportes
5. Validación
6. Asignaciones
7. Cuadrantes
8. Colecciones
9. Informes
10. Estadísticas
11. Alertas
12. Usuarios
13. Contactos de emergencia
14. Auditoría
15. Configuración

============================================================
7. IDENTIDAD VISUAL
============================================================

La marca principal será:

BUGA

No utilizar un logotipo oficial del municipio, Policía, Bomberos, Alcaldía, Basílica ni ninguna institución.

Crear una identidad propia.

CONCEPTO DEL LOGO:

Combinar visualmente:

- silueta simplificada de la Basílica del Señor de los Milagros de Buga
- ondas de radar
- señal de alerta
- línea tipo electrocardiograma/pulso
- concepto de geolocalización

La Basílica debe utilizarse como REFERENCIA VISUAL simplificada, no como copia exacta de una fotografía.

Debe existir:

- isotipo
- logotipo BUGA
- versión horizontal
- versión vertical
- icono de aplicación
- favicon

Concepto:

             ╭──────╮
          )) │ BUGA │ ((
             ╰─╥──╥─╯
               ║  ║
              ─╨──╨─
               /\/\

CONCEPTO DE MARCA:

BUGA
Reporta. Ubica. Actúa.

Estética:

- tecnológica
- ciudadana
- moderna
- profesional
- limpia
- confiable
- inspirada sutilmente en Buga

Paleta sugerida:

- borgoña/rojo ladrillo como color principal
- blanco hueso
- gris carbón
- verde/teal para estados positivos
- amarillo para advertencia
- naranja para riesgo
- rojo para crítico

No abusar del rojo.

La UI debe estar diseñada para parecer una plataforma civic-tech real.

Utilizar la imagen conceptual proporcionada por el usuario como REFERENCIA DE DIRECCIÓN VISUAL.

============================================================
8. APP CIUDADANA — FLUJO PRINCIPAL
============================================================

Cuando el usuario pulse:

"REPORTAR INCIDENTE"

debe comenzar este flujo:

PASO 1
Solicitar permiso de ubicación.

PASO 2
Obtener ubicación actual.

Registrar:

latitude
longitude
accuracy
timestamp

PASO 3
Abrir cámara.

PASO 4
El usuario toma la fotografía.

En el instante de la captura guardar:

capture_at_device
capture_latitude
capture_longitude
capture_accuracy
capture_source = APP_CAMERA

PASO 5
Leer/registrar metadata EXIF cuando exista.

PASO 6
Mostrar pantalla de confirmación:

----------------------------------
EVIDENCIA CAPTURADA

📷 Fotografía

📍 Ubicación capturada
3.xxxxxx, -76.xxxxxx

Precisión
8 m

🕐 Captura
25/09/2026 09:34

Fuente:
GPS del dispositivo

----------------------------------

PASO 7
Seleccionar categoría:

- Hueco
- Daño de pavimento
- Servicios públicos
- Evento comunitario
- Otro

PASO 8
Descripción.

PASO 9
Mostrar mapa.

El punto GPS debe aparecer automáticamente.

El usuario podrá:

- confirmar
- ajustar manualmente la ubicación

SI EL USUARIO LA MODIFICA:

guardar:

original_latitude
original_longitude

final_latitude
final_longitude

location_user_adjusted = true

Nunca sobrescribir el dato original.

PASO 10
Confirmar reporte.

PASO 11
Guardar localmente.

PASO 12
Si no hay Internet:

estado = PENDING_SYNC

PASO 13
Si hay Internet:

iniciar sincronización.

============================================================
9. SISTEMA DE EVIDENCIA
============================================================

La evidencia debe tener una arquitectura de trazabilidad.

Crear:

capture_source

Valores:

APP_CAMERA
GALLERY
EXTERNAL_IMAGE

Crear:

location_source

Valores:

DEVICE_GPS_AT_CAPTURE
EXIF
USER_MANUAL
UNKNOWN

Crear:

evidence_integrity_level

Valores:

HIGH
MEDIUM
LOW
REVIEW

REGLAS:

HIGH:

- tomada desde cámara interna de la app
- GPS de dispositivo disponible durante captura
- timestamp de captura disponible
- archivo original conservado
- metadata consistente

MEDIUM:

- evidencia interna pero faltan algunos metadatos
- o precisión GPS elevada
- o inconsistencias menores

LOW:

- imagen externa
- sin GPS confiable
- metadata ausente

REVIEW:

- inconsistencias entre GPS interno y EXIF
- fechas extrañas
- metadata conflictiva
- evidencia modificada
- usuario modificó ubicación
- otras anomalías

NO presentar estos niveles como prueba legal.

Son indicadores de trazabilidad técnica.

============================================================
10. FECHAS
============================================================

NUNCA utilizar uploaded_at como fecha principal del incidente.

Guardar:

capture_at_device
exif_datetime_original
exif_gps_datetime
received_at_server
uploaded_at
file_modified_at
created_at
updated_at

Jerarquía para FECHA DE CAPTURA:

1. timestamp capturado por la aplicación
2. EXIF DateTimeOriginal
3. otra metadata EXIF
4. fecha manual declarada por el usuario
5. desconocida

Para imágenes externas:

1. EXIF DateTimeOriginal
2. EXIF GPS timestamp
3. fecha declarada por usuario
4. desconocida

Nunca inventar una fecha.

Guardar todas las fuentes.

Todas las fechas persistidas en base de datos deben estar correctamente normalizadas.

Usar UTC internamente y mostrar America/Bogota en UI cuando corresponda.

============================================================
11. GPS
============================================================

El backend debe almacenar:

capture_latitude
capture_longitude
capture_accuracy

Además:

exif_latitude
exif_longitude

Y:

final_latitude
final_longitude

Si el usuario cambia la ubicación:

location_user_adjusted = true

El backend debe comparar:

GPS capturado
vs
GPS EXIF

y generar:

location_consistency

Valores:

MATCH
CLOSE
DIFFERENT
UNKNOWN

No asumir manipulación automáticamente.

Registrar solamente una inconsistencia.

============================================================
12. EXIF Y EXIFTOOL
============================================================

Al recibir una fotografía:

1. guardar archivo original
2. calcular SHA-256
3. ejecutar ExifTool
4. extraer metadata
5. almacenar metadata normalizada
6. comparar GPS
7. comparar timestamps
8. determinar nivel de trazabilidad

Guardar:

photo_sha256

Además puede existir:

photo_phash

para búsqueda de posibles imágenes duplicadas.

NO confiar exclusivamente en metadata enviada por el cliente.

El backend debe volver a extraer EXIF directamente del archivo recibido.

============================================================
13. OFFLINE-FIRST
============================================================

La aplicación ciudadana debe poder funcionar sin Internet.

Crear almacenamiento SQLite local.

Cada reporte debe tener:

client_report_uuid

La sincronización debe ser IDEMPOTENTE.

No debe crearse el mismo reporte varias veces si el usuario pulsa reintentar.

Estados:

DRAFT
PENDING_SYNC
SYNCING
SYNCED
FAILED

La app debe almacenar localmente:

- reporte
- metadata
- fotografías
- estado de sincronización

Cuando vuelva Internet:

PENDING_SYNC
     ↓
SYNCING
     ↓
UPLOAD
     ↓
SERVER CONFIRMED
     ↓
SYNCED

Si falla:

FAILED

con botón:

REINTENTAR

Implementar reintentos seguros.

============================================================
14. COMPRESIÓN DE IMÁGENES
============================================================

Conservar una versión original siempre que sea viable.

Crear también:

- thumbnail
- preview
- versión optimizada

La vista administrativa debe utilizar preview/thumbnail.

El original debe utilizarse para:

- evidencia
- descarga
- EXIF
- hash
- informe

No eliminar el original automáticamente.

============================================================
15. MAPA
============================================================

La plataforma utilizará OpenStreetMap.

APP:

Mostrar:

- ubicación actual
- ubicación del incidente
- precisión
- posibilidad de confirmación

ADMIN:

Mostrar todos los reportes autorizados.

Marcadores con colores según severidad/estado.

Ejemplo:

🔴 Crítico
🟠 Alto
🟡 Medio
🟢 Bajo
⚪ Pendiente de validar

Implementar clustering cuando haya muchos puntos.

============================================================
16. CUADRANTES
============================================================

Crear sistema GIS mediante PostGIS.

Tabla:

quadrants

Campos mínimos:

id
code
name
description
geometry
source
version
active
created_at
updated_at

geometry:

MULTIPOLYGON SRID 4326

Cada reporte deberá determinar automáticamente:

quadrant_id

mediante operación espacial.

Ejemplo conceptual:

POINT
  ↓
PostGIS
  ↓
ST_Contains()
  ↓
Q-07

No hacer esta lógica exclusivamente en Flutter.

Debe vivir en backend/PostGIS.

Crear índices espaciales GiST.

============================================================
17. DATOS DE BUGA
============================================================

Preparar una capa GIS para Guadalajara de Buga.

Utilizar preferentemente:

OpenStreetMap
Overpass
Geofabrik
Datos abiertos oficiales

Descargar/importar únicamente los datos necesarios.

Evitar consultas masivas repetitivas contra APIs públicas.

Crear una estrategia local/cacheada.

Guardar información de procedencia:

source
source_url
retrieved_at
license
version

Si una delimitación de cuadrantes no puede verificarse oficialmente:

NO inventarla.

Marcarla como:

DEMO DATA
NO OFFICIAL

============================================================
18. DETALLE DE REPORTE EN ADMIN
============================================================

Al seleccionar un marcador:

abrir panel lateral o modal.

Debe mostrar:

----------------------------------

REP-0048

Hueco

🔴 Alta

📷 Fotografía

🕐 Fecha de captura

📍 Coordenadas

📏 Precisión

🗺 Cuadrante

📌 Barrio/sector cuando esté disponible

📝 Descripción

🔐 Trazabilidad de evidencia

GPS:
✓

EXIF:
✓

Timestamp:
✓

SHA-256:
✓

IA:
Hueco 94 %

Confianza:
82 %

Estado:

Pendiente de validación

----------------------------------

Acciones:

[VALIDAR]
[RECHAZAR]
[ASIGNAR]
[CAMBIAR ESTADO]
[SELECCIONAR]
[VER MAPA]
[DESCARGAR]

============================================================
19. WORKFLOW ADMINISTRATIVO
============================================================

Estados:

DRAFT
SUBMITTED
RECEIVED
IN_VALIDATION
VALIDATED
ASSIGNED
IN_PROGRESS
RESOLVED
CLOSED

Alternativos:

REJECTED
DUPLICATE

Cada cambio debe quedar en:

report_events

Ejemplo:

REP-0048

25/09 09:34
Creado

25/09 09:35
Recibido

25/09 10:04
Validado

25/09 10:06
Asignado a Q-07

25/09 14:32
En proceso

============================================================
20. ROLES
============================================================

Crear como mínimo:

CITIZEN
VALIDATOR
COORDINATOR
ADMIN

Opcional:

AUDITOR

CITIZEN:

- crear reportes
- consultar propios reportes
- gestionar borradores

VALIDATOR:

- revisar evidencias
- validar
- rechazar
- clasificar manualmente

COORDINATOR:

- asignar responsables
- modificar estados
- gestionar colecciones

ADMIN:

- todo
- usuarios
- configuración
- contactos
- cuadrantes
- auditoría

Aplicar RBAC en backend.

Nunca confiar solamente en esconder botones en frontend.

============================================================
21. REALTIME
============================================================

El panel administrativo debe recibir eventos en tiempo real.

Eventos:

REPORT_CREATED
REPORT_RECEIVED
REPORT_VALIDATION_REQUIRED
REPORT_CRITICAL
REPORT_ASSIGNED
REPORT_STATUS_CHANGED
REPORT_REJECTED
REPORT_DUPLICATE_DETECTED
AI_ANALYSIS_READY

Cuando un ciudadano envíe:

mostrar inmediatamente:

🔔 NUEVO REPORTE

REP-0048
Hueco
Q-07
Hace 5 segundos

Si el reporte es crítico:

🔴 INCIDENTE CRÍTICO

Separar:

A. Realtime con panel abierto

WebSocket o SSE

B. Panel cerrado

Web Push

============================================================
22. SERVICE WORKER
============================================================

La aplicación web administrativa deberá poder comportarse como PWA cuando sea viable.

Implementar:

- service worker
- manifest
- cache básica
- notificaciones push
- manejo de permisos
- lifecycle de suscripciones

No utilizar Service Worker como reemplazo de WebSocket.

Arquitectura:

Nuevo reporte
      ↓
FastAPI
      ↓
Evento
      ├── WebSocket/SSE → panel abierto
      │
      └── Push → Service Worker → notificación

============================================================
23. ALERTAS
============================================================

Crear centro de alertas.

Ejemplo:

🔴 Nuevo incidente crítico
REP-0048
Hace 12 segundos

🟠 Nuevo reporte
REP-0047
Hace 2 minutos

🟡 Validación pendiente
REP-0046

Permitir:

- marcar como leída
- abrir reporte
- filtrar
- prioridad
- fecha

============================================================
24. DASHBOARD
============================================================

Dashboard principal:

Tarjetas:

TOTAL REPORTES
PENDIENTES
CRÍTICOS
EN PROCESO
RESUELTOS

Visualizaciones:

- reportes por categoría
- reportes por severidad
- reportes por cuadrante
- tendencia temporal
- tiempo promedio de gestión
- mapa de calor
- distribución geográfica

Filtros globales:

- fecha de captura
- categoría
- severidad
- estado
- cuadrante
- fuente de evidencia
- nivel de trazabilidad

IMPORTANTE:

El filtro "fecha" debe permitir seleccionar:

FECHA DE CAPTURA
FECHA DE RECEPCIÓN
FECHA DE RESOLUCIÓN

La fecha predeterminada para análisis de incidentes será FECHA DE CAPTURA.

============================================================
25. COLECCIONES DE EVIDENCIAS
============================================================

Implementar:

COLECCIONES

Ejemplo:

"Daños viales septiembre 2026"

Una colección puede contener:

REP-0021
REP-0028
REP-0034
REP-0041
REP-0048

Acciones:

[VER]
[EDITAR]
[ELIMINAR]
[GENERAR PDF]
[EXPORTAR CSV]
[VER MAPA]

Permitir seleccionar reportes desde:

- tabla
- mapa
- detalle individual

============================================================
26. INFORMES PDF
============================================================

Implementar dos tipos.

------------------------------------------------------------
A. INFORME INDIVIDUAL
------------------------------------------------------------

Debe contener:

- logo BUGA
- código del reporte
- fotografía
- categoría
- descripción
- fecha de captura
- fecha de recepción
- coordenadas
- precisión
- cuadrante
- ubicación
- estado
- severidad
- fuente de evidencia
- nivel de trazabilidad
- resumen EXIF
- hash SHA-256
- resultado IA
- historial
- mapa

------------------------------------------------------------
B. INFORME CONSOLIDADO
------------------------------------------------------------

El administrador seleccionará múltiples evidencias.

Ejemplo:

5 reportes seleccionados

Generar:

INFORME CONSOLIDADO DE INCIDENTES

Guadalajara de Buga
Periodo de captura:
01/09/2026 - 25/09/2026

Resumen estadístico.

Mapa general.

Después:

INCIDENTE 1
fotografía
datos

INCIDENTE 2
fotografía
datos

etc.

Añadir:

- tabla resumen
- mapa general
- fotografías
- coordenadas
- cuadrante
- categoría
- severidad
- estado
- fecha de captura

Permitir:

DOWNLOAD PDF

============================================================
27. EXPORTACIÓN DE DATOS
============================================================

Además del PDF:

CSV
JSON
GeoJSON

GeoJSON debe permitir representar puntos geográficos.

Los datos exportados deben respetar los permisos del usuario.

============================================================
28. MAPA DENTRO DEL INFORME
============================================================

El PDF debe incluir un mapa estático.

Debe mostrar:

- punto del incidente
- calles cercanas
- cuadrante
- contexto geográfico

Preferentemente utilizar OpenStreetMap.

No depender de APIs pagas.

Para renderización se puede utilizar:

- Playwright
- Chromium headless
- HTML
- Leaflet

o una alternativa equivalente.

============================================================
29. VISTA DE IMAGEN DE CALLE
============================================================

Crear arquitectura opcional para consultar imágenes abiertas a nivel de calle cuando exista cobertura.

Nunca depender obligatoriamente de Google Street View.

El módulo debe fallar de manera elegante:

"Vista de calle no disponible para esta ubicación."

No romper el reporte.

============================================================
30. EMERGENCIAS
============================================================

La APP CIUDADANA debe incluir una opción visible:

🚨 EMERGENCIA

Debe indicar claramente:

"Para una emergencia inmediata utiliza las líneas oficiales de atención."

Botones:

📞 Policía / Emergencias
🔥 Bomberos
⛑ Cruz Roja / Atención
🛟 Defensa Civil

El sistema debe permitir configurar:

name
type
phone
whatsapp
message_template
active
source
last_verified_at

NO hardcodear definitivamente los contactos en Flutter.

Los números deben poder actualizarse desde el panel administrativo.

Actualmente como datos iniciales de referencia en Colombia se pueden contemplar:

123
119
132
144

pero deben verificarse nuevamente desde fuentes oficiales durante la implementación y almacenarse como configuración.

Para Buga, cualquier número directo de entidad debe venir de una fuente institucional verificable.

NUNCA inventar un WhatsApp institucional.

Si no existe un WhatsApp oficialmente verificable:

no mostrar botón WhatsApp para dicha entidad.

============================================================
31. MENSAJES DE WHATSAPP
============================================================

Cuando exista un WhatsApp institucional verificado:

Abrir el chat con un mensaje prellenado.

Ejemplo:

🚨 SOLICITUD DE ASISTENCIA

Tipo:
Accidente / Incidente

Necesito asistencia.

📍 Ubicación:
latitud, longitud

Mapa:
[enlace]

🕐 Hora:
fecha/hora

IMPORTANTE:

El usuario debe entrar al chat y pulsar ENVIAR.

La plataforma NO debe afirmar que envió el mensaje automáticamente.

Antes de abrir WhatsApp:

mostrar:

"Se abrirá WhatsApp con este mensaje preparado. Revisa la información antes de enviarlo."

============================================================
32. EMERGENCIAS NO DEBEN DEPENDER DEL BACKEND
============================================================

El botón para llamar a un número de emergencia debe funcionar incluso con conectividad limitada siempre que el dispositivo permita realizar la llamada.

No obligar al ciudadano a iniciar sesión para acceder a emergencias.

La función de emergencia debe ser independiente del flujo normal de reportes.

============================================================
33. PRIVACIDAD
============================================================

Implementar:

- política de privacidad
- consentimiento
- minimización de datos
- control de acceso
- protección de fotografías
- logs
- auditoría
- no exposición pública de datos personales

Las fotografías originales deben estar protegidas.

No exponer públicamente:

- identidad del ciudadano
- teléfono
- email
- coordenadas exactas del domicilio del usuario
- metadata innecesaria

Para vistas públicas, si en el futuro existieran:

aplicar anonimización/limitación.

============================================================
34. SEGURIDAD
============================================================

Implementar mínimo:

- JWT
- refresh tokens si corresponde
- password hashing seguro
- RBAC
- validación Pydantic
- rate limiting donde corresponda
- límites de tamaño de archivos
- MIME validation
- extensión + contenido real
- sanitización de nombres de archivo
- UUIDs
- protección CORS
- configuración por environment
- secrets fuera del repositorio
- logs
- auditoría

No confiar en:

- roles enviados por frontend
- IDs enviados sin autorización
- nombres de archivo
- EXIF
- fechas del cliente

============================================================
35. AUDITORÍA
============================================================

Crear:

audit_logs

Registrar:

- usuario
- acción
- entidad
- entidad_id
- timestamp
- IP si corresponde
- cambios relevantes

Ejemplos:

REPORT_CREATED
REPORT_VIEWED
REPORT_VALIDATED
REPORT_REJECTED
REPORT_ASSIGNED
REPORT_STATUS_CHANGED
REPORT_EXPORTED
REPORT_DELETED
USER_CREATED
USER_ROLE_CHANGED

IMPORTANTE:

No eliminar físicamente una evidencia importante sin dejar trazabilidad.

Preferir soft-delete cuando corresponda.

============================================================
36. DUPLICADOS
============================================================

Implementar una primera versión basada en:

- distancia geográfica
- categoría
- intervalo temporal
- perceptual hash

Ejemplo:

REP-0021
REP-0029
REP-0031

Todos:

misma categoría
<30m
mismo periodo
imágenes similares

Mostrar:

⚠ POSIBLES DUPLICADOS

Nunca fusionar automáticamente.

El administrador decide:

[UNIFICAR]
[MANTENER SEPARADOS]

============================================================
37. IA
============================================================

NO implementar IA antes de que el MVP funcione.

La IA es una extensión.

Arquitectura:

Flutter
 ↓
FastAPI
 ↓
AI Service
 ↓
modelo
 ↓
resultado JSON

Ejemplo:

{
  "category": "hueco",
  "confidence": 0.94,
  "severity": "alta",
  "severity_confidence": 0.82
}

La IA NO debe reemplazar al evaluador humano.

Mostrar:

"Predicción de IA"

y:

"Validado por operador"

como campos separados.

============================================================
38. IA — FASE 1
============================================================

Clasificación:

- hueco
- grieta
- daño de pavimento
- inundación
- servicios
- otro

============================================================
39. IA — FASE 2
============================================================

Object detection / segmentation.

Detectar ubicación del daño.

Guardar:

bounding boxes
masks
confidence

============================================================
40. IA — FASE 3
============================================================

Estimación de severidad.

La IA puede sugerir:

BAJA
MEDIA
ALTA
CRÍTICA

Pero debe mostrar confianza.

============================================================
41. IA — FASE 4
============================================================

Detección de duplicados visuales.

Utilizar:

pHash
embeddings
modelo visual

según viabilidad.

============================================================
42. IA — FASE 5 — INNOVACIÓN
============================================================

Implementar opcionalmente:

estimación de profundidad

Arquitectura conceptual:

FOTO
 ↓
SEGMENTACIÓN DEL HUECO
 ↓
DEPTH ESTIMATION
 ↓
REFERENCIA VISUAL
 ↓
ESCALA
 ↓
ESTIMACIÓN

La aplicación NO debe afirmar que una fotografía monocular cualquiera puede medir con exactitud centímetros reales.

Crear un modo:

"MODO MEDICIÓN"

El usuario coloca una referencia conocida:

- tarjeta
- moneda
- marcador
- objeto de tamaño conocido

en el mismo plano del daño.

La interfaz debe guiar al ciudadano.

Resultado:

"Estimación experimental"

Nunca:

"Medida exacta"

============================================================
43. DATASET IA
============================================================

Crear estructura:

/dataset

/huecos
/grietas
/alumbrado
/inundaciones
/otros

Crear documentación:

- origen
- licencia
- categoría
- anotación
- train
- validation
- test

No utilizar imágenes sin verificar licencias.

Los 50 reportes del SMART NO constituyen un dataset suficiente para afirmar rendimiento robusto del modelo.

El sistema debe diferenciar:

DATOS DE PRUEBA DEL SISTEMA

de:

DATASET DE ENTRENAMIENTO

============================================================
44. API
============================================================

Crear API REST documentada con OpenAPI.

Endpoints mínimos:

POST /auth/login

GET /reports
POST /reports
GET /reports/{id}
PATCH /reports/{id}
DELETE /reports/{id}

POST /reports/{id}/media

POST /reports/{id}/validate
POST /reports/{id}/assign
POST /reports/{id}/status

GET /reports/map

GET /quadrants

GET /categories

GET /statistics

GET /alerts

POST /collections
GET /collections
POST /collections/{id}/items

POST /exports/pdf
POST /exports/csv

GET /emergency-contacts

POST /ai/analyze/{report_id}

WS /realtime

o SSE equivalente.

Todos los endpoints administrativos deben requerir autorización.

============================================================
45. IDEMPOTENCIA
============================================================

Los reportes enviados offline deben usar:

client_report_uuid

El backend debe rechazar duplicaciones lógicas.

Ejemplo:

POST REP-UUID-123
→ crea reporte

mismo POST otra vez
→ devuelve reporte existente

No crear dos reportes.

============================================================
46. BASE DE DATOS
============================================================

Crear como mínimo:

users
roles
user_roles

reports
report_media
report_metadata

categories
severities
statuses

quadrants
assignments

report_events
audit_logs

collections
collection_items

emergency_contacts

ai_analysis
ai_predictions

notifications
push_subscriptions

Se pueden agregar tablas si mejoran el diseño.

============================================================
47. REPORTS
============================================================

Campos conceptuales:

id
client_report_uuid
public_code

user_id

category_id
severity_id
status_id
quadrant_id

description

capture_at_device
received_at_server
uploaded_at

capture_latitude
capture_longitude
capture_accuracy

final_latitude
final_longitude

location_user_adjusted
location_source

evidence_integrity_level

created_at
updated_at

PostGIS:

location geometry(Point,4326)

Crear índice espacial.

============================================================
48. REPORT MEDIA
============================================================

Campos:

id
report_id

storage_key
original_filename

mime_type
file_size

sha256
phash

thumbnail_key
preview_key

capture_source

created_at

============================================================
49. REPORT METADATA
============================================================

Guardar:

exif_datetime_original
exif_gps_latitude
exif_gps_longitude
exif_gps_datetime
camera_make
camera_model

y metadata relevante.

Si no existe:

NULL

Nunca crear valores falsos.

============================================================
50. ADMIN — FILTROS
============================================================

Filtros:

Categoría
Estado
Severidad
Cuadrante
Fecha de captura
Fecha de recepción
Fecha de resolución
Nivel de evidencia
Fuente de evidencia
IA
Validación

Permitir combinar múltiples filtros.

============================================================
51. ADMIN — TABLA
============================================================

Columnas:

Código
Foto
Categoría
Fecha captura
Ubicación
Cuadrante
Severidad
Evidencia
IA
Estado
Responsable
Acciones

============================================================
52. ADMIN — MAPA
============================================================

Mostrar:

clusters
marcadores
colores
cuadrantes
heatmap

Al hacer click:

abrir detalle.

Permitir:

- seleccionar marcador
- incluir en colección
- abrir reporte
- validar
- filtrar

============================================================
53. COLORES DEL MAPA
============================================================

CRÍTICO → rojo

ALTO → naranja

MEDIO → amarillo

BAJO → verde

PENDIENTE → gris

Los colores deben ser accesibles y no depender exclusivamente del color.

Agregar iconos/texto cuando sea necesario.

============================================================
54. REPORTES PÚBLICOS VS PRIVADOS
============================================================

Por defecto:

Los ciudadanos solo pueden ver sus propios reportes.

El panel administrativo puede ver los reportes autorizados.

No crear un mapa público global de incidentes sin aplicar controles de privacidad.

============================================================
55. UX
============================================================

La app ciudadana debe ser sencilla.

Un ciudadano no debe necesitar conocimiento técnico.

El flujo para reportar debe minimizar pasos.

El botón principal:

+ REPORTAR INCIDENTE

debe ser muy visible.

La emergencia:

🚨 EMERGENCIA

debe ser accesible pero visualmente separada del flujo normal.

============================================================
56. ACCESIBILIDAD
============================================================

Implementar:

- textos legibles
- contraste
- labels
- botones grandes
- soporte para lectores cuando sea viable
- no usar solamente color como indicador
- mensajes claros
- estados de carga
- mensajes de error útiles

============================================================
57. ERROR HANDLING
============================================================

Nunca mostrar:

"Exception"
"NullPointer"
"500 Internal"

al usuario final.

Mostrar:

"No fue posible sincronizar el reporte."

y permitir:

[REINTENTAR]

Pero registrar el error internamente.

============================================================
58. TESTING
============================================================

Cada fase deberá incorporar pruebas.

Backend:

- unit tests
- integration tests
- API tests
- database tests

Flutter:

- unit tests
- widget tests
- integration tests

Frontend:

- component tests
- integration tests

GIS:

- pruebas de point-in-polygon
- pruebas de límites
- coordenadas inválidas

Offline:

- reporte sin Internet
- recuperación
- reintentos
- duplicados

EXIF:

- imagen con EXIF
- imagen sin EXIF
- GPS diferente
- fecha diferente

PDF:

- informe individual
- informe múltiple
- 50 reportes

Realtime:

- reporte nuevo
- notificación
- reconexión

IA:

- validación de formato
- confidence
- error handling
- modelo no disponible

============================================================
59. TEST ESPECIAL DEL CASO DE LA FECHA
============================================================

Crear específicamente este escenario:

Usuario toma foto:
09:30 Buga

No tiene Internet.

Se desplaza.

12:45 recupera Internet.

Sube la foto.

El sistema debe mostrar:

Fecha de captura:
09:30

Fecha de recepción:
12:45

Nunca sustituir:

09:30

por:

12:45

============================================================
60. TEST ESPECIAL DEL CASO GPS
============================================================

Caso:

Foto tomada:

Buga

Envío:

Cali

Resultado:

capture_latitude = Buga
capture_longitude = Buga

received_at = Cali/otro momento

La ubicación del reporte NO debe cambiar automáticamente a la ubicación al momento de sincronización.

============================================================
61. TEST ESPECIAL DE GALERÍA
============================================================

Usuario selecciona una fotografía antigua de galería.

Si tiene EXIF:

mostrar:

"Imagen externa"

Fecha EXIF:
...

Ubicación EXIF:
...

No afirmar:

"Foto tomada ahora."

Si no tiene metadata:

mostrar:

"Fecha y ubicación de captura no disponibles."

============================================================
62. DOCKER
============================================================

Crear:

docker-compose.yml

Servicios iniciales:

postgres-postgis
minio
backend

Opcional:

redis

ai-service

web

Debe ser posible ejecutar:

docker compose up

Documentar configuración.

============================================================
63. VARIABLES DE ENTORNO
============================================================

Nunca hardcodear:

passwords
JWT secrets
MinIO credentials
database credentials
API keys

Crear:

.env.example

Ejemplo:

DATABASE_URL=
JWT_SECRET=
MINIO_ENDPOINT=
MINIO_ACCESS_KEY=
MINIO_SECRET_KEY=
MINIO_BUCKET=
APP_ENV=

============================================================
64. ESTRUCTURA DE REPOSITORIO
============================================================

Proponer y mantener una estructura clara.

Ejemplo:

/buga

/apps
    /citizen_app
    /admin_web

/services
    /api
    /ai

/packages
    /shared

/infrastructure
    /docker

/data
    /geo
    /seed

/docs
    /architecture
    /api
    /database
    /scrum
    /privacy
    /testing
    /ai

/scripts

/tests

README.md

============================================================
65. DOCUMENTACIÓN
============================================================

Crear y mantener:

README.md

ARCHITECTURE.md

DATABASE.md

API.md

GIS.md

EVIDENCE.md

OFFLINE_SYNC.md

REALTIME.md

SECURITY.md

PRIVACY.md

AI.md

DEPLOYMENT.md

TESTING.md

LICENSES.md

============================================================
66. LICENCIAS
============================================================

Antes de reutilizar código de terceros:

1. identificar repositorio
2. revisar licencia
3. revisar archivo concreto
4. revisar dependencias
5. documentar procedencia
6. conservar notices cuando corresponda

No copiar código simplemente porque está en GitHub.

Utilizar los repositorios de referencia principalmente como inspiración arquitectónica y funcional.

============================================================
67. REPOSITORIOS DE REFERENCIA
============================================================

Utilizar estos proyectos como referencias de diseño/arquitectura:

SnapFix AI

Referencia:
- civic reporting
- EXIF
- geospatial
- dashboard
- AI
- PDF
- duplicate detection

CivicLens

Referencia:
- offline-first
- SQLite
- sincronización
- roles
- realtime
- PostGIS
- dashboard

FixMyStreet

Referencia:
- modelo ciudadano
- problemas urbanos
- geolocalización
- asignación a autoridades
- flujo administrativo

Ushahidi

Referencia:
- crowdsourcing
- georreferenciación
- mapas
- gestión de incidentes

InfraSight

Referencia:
- segmentación
- depth estimation
- referencia de escala
- mediciones experimentales
- PDF

NO copiar arquitecturas completas sin análisis.

============================================================
68. DESARROLLO AGENTICO
============================================================

Divide el trabajo internamente entre agentes especializados.

Puedes crear roles internos:

AGENT-ARCHITECT
AGENT-BACKEND
AGENT-FLUTTER
AGENT-FRONTEND
AGENT-GIS
AGENT-DEVOPS
AGENT-SECURITY
AGENT-QA
AGENT-AI
AGENT-DOCS

El agente principal debe coordinar.

Ningún agente debe modificar arbitrariamente módulos de otro sin entender su contrato.

============================================================
69. REGLA DE CONTRATOS
============================================================

Antes de implementar una parte:

definir:

- input
- output
- endpoint
- modelo
- errores
- permisos
- tests

Ejemplo:

Citizen App
POST /reports

Debe estar documentado antes de conectar frontend/backend.

============================================================
70. MIGRACIONES
============================================================

Utilizar migraciones.

No modificar producción/base de datos manualmente.

Usar Alembic.

Cada cambio de schema:

migration

============================================================
71. GIT
============================================================

Trabajar con commits pequeños.

Ejemplos:

feat(citizen): add GPS capture
feat(backend): create reports endpoint
feat(gis): automatic quadrant assignment
feat(admin): add report map
feat(realtime): add report notifications
fix(sync): prevent duplicated offline reports

No realizar un único commit gigante.

============================================================
72. FASES DE DESARROLLO
============================================================

============================================================
FASE 0 — DESCUBRIMIENTO
============================================================

Objetivo:

comprender el proyecto antes de programar.

Tareas:

- analizar repositorios de referencia
- revisar licencias
- revisar tecnologías
- definir arquitectura
- definir database schema
- definir API
- definir UX
- definir identidad visual
- definir carpetas
- definir Docker

Entregables:

ARCHITECTURE.md
DATABASE.md
API.md
README inicial

NO implementar funcionalidades grandes todavía.

GATE:

Arquitectura aprobada internamente.

============================================================
FASE 1 — BOOTSTRAP
============================================================

Crear:

- monorepo
- Flutter
- admin web
- FastAPI
- PostgreSQL/PostGIS
- MinIO
- Docker Compose
- CI básica
- lint
- tests

GATE:

Todo levanta localmente.

============================================================
FASE 2 — APP CIUDADANA BÁSICA
============================================================

Implementar:

- inicio
- permisos
- GPS
- cámara
- categorías
- descripción
- mapa
- creación de reporte

GATE:

Usuario puede crear reportes de prueba.

============================================================
FASE 3 — EVIDENCIA + OFFLINE
============================================================

Implementar:

- SQLite
- borradores
- offline
- sincronización
- idempotencia
- EXIF
- SHA-256
- GPS de captura
- fechas

GATE:

El caso Buga → Cali debe funcionar correctamente.

============================================================
FASE 4 — GIS
============================================================

Implementar:

- PostGIS
- mapas
- cuadrantes
- point-in-polygon
- geodatos Buga
- clustering

GATE:

>=90% de los reportes de prueba pueden asignarse correctamente a cuadrante.

============================================================
FASE 5 — ADMIN
============================================================

Implementar:

- login
- RBAC
- dashboard
- tabla
- filtros
- mapa
- detalle
- validación
- estados
- asignaciones

GATE:

50 reportes pueden administrarse correctamente.

============================================================
FASE 6 — REALTIME + ALERTAS
============================================================

Implementar:

- WebSocket/SSE
- eventos
- alertas
- Service Worker
- Web Push
- reconexión

GATE:

Crear reporte desde móvil.

Panel recibe alerta.

============================================================
FASE 7 — COLECCIONES + PDF
============================================================

Implementar:

- seleccionar evidencias
- colecciones
- PDF individual
- PDF consolidado
- CSV
- GeoJSON

GATE:

Seleccionar >=5 reportes y generar PDF correcto.

============================================================
FASE 8 — EMERGENCIAS
============================================================

Implementar:

- pantalla emergencia
- llamada
- contactos configurables
- mensajes WhatsApp
- ubicación prellenada
- confirmación antes de enviar

GATE:

Flujo seguro y funcional.

============================================================
FASE 9 — IA
============================================================

Implementar:

- clasificación
- detección
- severidad
- confidence
- servicio IA separado

GATE:

IA funciona sin bloquear la plataforma.

============================================================
FASE 10 — IA AVANZADA
============================================================

Opcional:

- segmentación
- depth
- medición experimental
- referencia visual

GATE:

Presentar resultados como estimaciones, no como mediciones forenses absolutas.

============================================================
FASE 11 — SEGURIDAD + QA
============================================================

Implementar:

- security audit
- permisos
- rate limit
- validaciones
- pruebas
- cargas
- recuperación
- errores
- logs

============================================================
FASE 12 — ENTREGA ACADÉMICA
============================================================

Preparar:

- README final
- arquitectura
- ER
- diagramas
- manual usuario
- manual administrador
- pruebas
- métricas SMART
- screenshots
- demo
- documentación IA
- documentación Scrum
- limitaciones
- trabajo futuro

============================================================
73. CRITERIOS DE CALIDAD
============================================================

No dar por terminada una fase porque:

"el código compila".

Una fase termina cuando:

- funciona
- tiene tests
- está documentada
- maneja errores
- no rompe funcionalidades anteriores
- tiene criterios de aceptación cumplidos

============================================================
74. REGLA PARA DEPENDENCIAS
============================================================

Antes de añadir una dependencia:

1. verificar si realmente es necesaria
2. verificar compatibilidad actual
3. verificar licencia
4. verificar mantenimiento
5. evitar dependencias duplicadas
6. documentarla

No fijar versiones arbitrarias.

Utilizar versiones compatibles y actuales verificadas al momento de implementar.

============================================================
75. REGLA DE CAMBIOS
============================================================

Si existe código funcionando:

NO reescribirlo completamente por comodidad.

Hacer cambios incrementales.

Antes de refactorizar:

- identificar problema
- justificar cambio
- ejecutar tests

============================================================
76. REGLA SOBRE IA
============================================================

No utilizar IA generativa para funciones donde un algoritmo determinista sea suficiente.

Ejemplo:

Cuadrante:
PostGIS

NO:
LLM

Categoría:
Puede usar IA

Severidad:
IA + reglas

PDF:
código determinista

Realtime:
WebSocket/SSE

GPS:
API del dispositivo

Esto reduce costos y aumenta confiabilidad.

============================================================
77. OBJETIVO FINAL DEL PRODUCTO
============================================================

El resultado final deberá sentirse como una plataforma civic-tech real.

El ciudadano debe poder:

Tomar fotografía
↓
Obtener GPS
↓
Registrar incidente
↓
Guardar offline
↓
Sincronizar
↓
Consultar estado

El sistema debe:

extraer evidencia
↓
analizar metadata
↓
determinar ubicación
↓
determinar cuadrante
↓
clasificar
↓
notificar
↓
mostrar en mapa
↓
asignar
↓
gestionar
↓
auditar
↓
exportar

Y el administrador debe poder:

ver
↓
filtrar
↓
seleccionar
↓
validar
↓
asignar
↓
actualizar
↓
recopilar
↓
generar PDF

============================================================
78. DEFINICIÓN DE ÉXITO
============================================================

El sistema debe demostrar:

✓ mínimo 50 reportes de prueba
✓ fotografía
✓ descripción
✓ GPS
✓ fecha real de captura
✓ metadata
✓ funcionamiento offline
✓ sincronización
✓ clasificación
✓ cuadrantes
✓ mapa
✓ dashboard
✓ filtros
✓ validación
✓ estados
✓ asignaciones
✓ realtime
✓ alertas
✓ selección múltiple
✓ PDF
✓ exportación
✓ emergencias
✓ seguridad
✓ auditoría

Y como innovación:

✓ IA

Opcional avanzado:

✓ profundidad/dimensiones experimentales

============================================================
79. REGLA FINAL PARA EL AGENTE
============================================================

NO construyas una demo falsa.

Construye un sistema funcional.

NO simules:

- GPS
- backend
- sincronización
- realtime
- PDF
- autenticación
- PostGIS

cuando sea posible implementarlos realmente.

Las cosas que sean DEMO DATA deben identificarse claramente.

La plataforma debe ser explicable.

Cada decisión técnica importante debe quedar documentada.

Antes de cada fase:

PLAN.

Durante la fase:

IMPLEMENTACIÓN.

Después:

TEST.

Después:

DOCUMENTACIÓN.

Después:

COMMIT.

Y solamente entonces:

SIGUIENTE FASE.

No avanzar si una fase no cumple sus criterios.

============================================================
80. PRIMERA ACCIÓN
============================================================

NO empezar creando pantallas inmediatamente.

Primero:

1. inspeccionar el entorno
2. analizar los repositorios de referencia
3. comprobar tecnologías actuales compatibles
4. proponer estructura de repositorio
5. crear arquitectura
6. crear modelo de datos
7. crear contratos API
8. crear roadmap técnico
9. definir criterios de aceptación
10. presentar el PLAN DE FASE 0

Después de eso comenzar la implementación.

============================================================
FIN DEL PROMPT MAESTRO
============================================================