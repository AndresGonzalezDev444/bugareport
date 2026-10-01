<div align="center">

<img src="images/LOGO-BUGAREPORT.png" alt="BugaReport Logo" width="280"/>

<br/>

# BugaReport

### Plataforma Digital de Reporte Ciudadano Georreferenciado para Cuadrantes de Buga

**Ciudadanos que reportan · Una ciudad que avanza**

<br/>

[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![TypeScript](https://img.shields.io/badge/Web-TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![TailwindCSS](https://img.shields.io/badge/Style-TailwindCSS-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![ExifTool](https://img.shields.io/badge/Metadata-ExifTool-FF6B35?style=for-the-badge&logoColor=white)](https://exiftool.org)
[![License](https://img.shields.io/badge/License-MIT-22C55E?style=for-the-badge)](LICENSE)

</div>

---

## ¿Qué es BugaReport?

**BugaReport** es una plataforma digital integral que permite a los ciudadanos de **Guadalajara de Buga, Valle del Cauca, Colombia**, reportar incidentes en tiempo real, geolocalizados y organizados por cuadrantes, para que las autoridades y entidades puedan gestionarlos de manera eficiente.

> **Tecnología + Ciudadanía = Una Buga mejor**

La plataforma conecta a los ciudadanos con la Alcaldía, Policía Nacional, Bomberos, Cruz Roja, Defensa Civil y empresas de servicios públicos, facilitando una respuesta rápida, coordinada y transparente ante cualquier incidente urbano.

---

## Arquitectura del Sistema

```
BugaReport/
├── user-panel-mobile/      # Aplicación móvil ciudadana (Flutter)
├── admin-panel/            # Panel web de administración (HTML · CSS · JS · TS · Tailwind)
├── images/                 # Recursos gráficos del proyecto
└── README.md
```

El sistema se compone de **tres capas principales**:

```
┌─────────────────────────────────────────────────────────────┐
│                    CIUDADANOS / USUARIOS                     │
│              App Móvil Flutter  (iOS & Android)              │
└─────────────────────────┬───────────────────────────────────┘
                          │  REST API / WebSockets
┌─────────────────────────▼───────────────────────────────────┐
│                     BACKEND / SERVIDOR                       │
│         PostgreSQL · ExifTool · Geolocalización              │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                   ADMINISTRADORES                            │
│        Panel Web  (TypeScript · TailwindCSS · HTML)          │
└─────────────────────────────────────────────────────────────┘
```

---

## Stack Tecnológico

### ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white) App Móvil — `user-panel-mobile/`

La aplicación ciudadana desarrollada en **Flutter** permite:

- Reportar incidentes con foto, descripción y ubicación GPS en tiempo real
- Consultar el estado de reportes enviados
- Visualizar el mapa de cuadrantes de Buga
- Recibir notificaciones push sobre el estado de sus reportes
- Funcionamiento multiplataforma: **iOS y Android**

---

### ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=flat-square&logo=postgresql&logoColor=white) Base de Datos — PostgreSQL

La base de datos relacional **PostgreSQL** gestiona:

- Registro y autenticación de usuarios y administradores
- Almacenamiento de reportes ciudadanos con coordenadas GPS
- Organización por cuadrantes de policía
- Historial de gestión y resolución de incidentes
- Metadatos extraídos de imágenes adjuntas

---

### ![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white) Panel Web Admin — `admin-panel/`

Panel de administración web desarrollado con **TypeScript + TailwindCSS + HTML**:

- Dashboard con métricas en tiempo real de reportes por cuadrante
- Gestión, validación y asignación de reportes a entidades competentes
- Visualización geográfica de incidentes activos en mapa interactivo
- Gestión de usuarios, roles y entidades aliadas
- Exportación de informes y análisis de datos

---

### ![ExifTool](https://img.shields.io/badge/ExifTool-FF6B35?style=flat-square&logoColor=white) Metadatos de Imágenes — ExifTool

**ExifTool** se utiliza para extraer y validar los metadatos de las fotografías adjuntas a los reportes:

- Extracción de coordenadas GPS embebidas en la imagen
- Verificación de fecha y hora de captura
- Detección de dispositivo y cámara de origen
- Validación de autenticidad del reporte
- Cruce de metadatos con la ubicación declarada por el usuario

---

## Propuesta de Valor

| Beneficio | Descripción |
|---|---|
| **Respuesta rápida** | Los reportes llegan en tiempo real a las entidades responsables |
| **Geolocalización precisa** | Cada incidente se ubica en el cuadrante correcto de la ciudad |
| **Trazabilidad** | Los ciudadanos pueden seguir el estado de sus reportes |
| **Coordinación interinstitucional** | Alcaldía, Policía, Bomberos, Cruz Roja y más, en un solo sistema |
| **Datos para decisiones** | Análisis de tendencias para mejorar la seguridad y los servicios |
| **Acceso universal** | Disponible para iOS y Android, con interfaz web para administradores |

---

## Alianzas Clave

<table>
<tr>
<td>

**Entidades Gubernamentales**
- Alcaldía de Guadalajara de Buga
- Policía Nacional
- Bomberos
- Defensa Civil
- Cruz Roja

</td>
<td>

**Servicios Públicos**
- Energía eléctrica
- Acueducto
- Alcantarillado
- Aseo urbano

</td>
<td>

**Sector Tecnológico y Académico**
- Universidades y centros de investigación
- Proveedores de GPS, mapas, nube e IA
- Empresas de infraestructura y mantenimiento

</td>
</tr>
</table>

---

## Canales de Distribución

- ![Android](https://img.shields.io/badge/Google_Play-414141?style=flat-square&logo=google-play&logoColor=white) **Google Play Store** — App móvil para Android
- ![iOS](https://img.shields.io/badge/App_Store-0D96F6?style=flat-square&logo=app-store&logoColor=white) **Apple App Store** — App móvil para iOS
- ![Web](https://img.shields.io/badge/Web_Admin-1E293B?style=flat-square&logo=google-chrome&logoColor=white) **Panel Web** — Acceso exclusivo para administradores y entidades
- ![Social](https://img.shields.io/badge/Redes_Sociales-E1306C?style=flat-square&logo=instagram&logoColor=white) **Redes sociales** y **medios de comunicación locales**
- **Puntos de atención presencial** en la Alcaldía y entidades aliadas

---

## Segmentos de Clientes

| Segmento | Descripción |
|---|---|
| **Ciudadanos** | Residentes y visitantes de Guadalajara de Buga |
| **Cuadrantes de Policía** | Unidades territoriales de seguridad |
| **Entidades de Emergencia** | Bomberos, Cruz Roja, Defensa Civil |
| **Empresas de Servicios** | Prestadores de servicios públicos |
| **Alcaldía y dependencias** | Entidades municipales y de gobierno |
| **Medios de comunicación** | Medios locales y comunitarios |
| **Administradores del sistema** | Analistas y coordinadores de la plataforma |

---

## Fuentes de Ingreso

- **Presupuesto público** — Alcaldía de Buga y entidades gubernamentales
- **Convenios y alianzas estratégicas**
- **Patrocinios de empresas privadas**
- **Fondos de innovación y tecnología**
- **Servicios adicionales** — Reportes especializados, análisis de datos, generación de informes

---

## Estructura de Costos

- Desarrollo y mantenimiento de la plataforma tecnológica
- Infraestructura en la nube y servicios de geolocalización
- Personal: desarrollo, administración, soporte, analistas
- Marketing y comunicación
- Capacitación y alianzas estratégicas
- Costos operativos y administrativos

---

## Instalación y Desarrollo

### Requisitos Previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `>= 3.x`
- [PostgreSQL](https://www.postgresql.org/download/) `>= 15`
- [Node.js](https://nodejs.org/) `>= 18` (para el panel admin)
- [ExifTool](https://exiftool.org/) instalado en el sistema

### App Móvil (Flutter)

```bash
cd user-panel-mobile
flutter pub get
flutter run
```

### Panel de Administración Web

```bash
cd admin-panel
# Abrir index.html en tu navegador
# O usar un servidor local:
npx serve .
```

### Base de Datos

```bash
# Crear base de datos
psql -U postgres -c "CREATE DATABASE bugareport;"

# Ejecutar migraciones
psql -U postgres -d bugareport -f database/schema.sql
```

### ExifTool — Extracción de Metadatos

```bash
# Verificar instalación
exiftool -ver

# Extraer coordenadas GPS de una imagen
exiftool -GPSLatitude -GPSLongitude imagen_reporte.jpg
```

---

## Estructura del Repositorio

```
BugaReport/
│
├── user-panel-mobile/         # App Flutter para ciudadanos
│
├── admin-panel/               # Panel web para administradores
│   ├── index.html             # Punto de entrada del panel
│   ├── css/                   # Estilos con TailwindCSS
│   ├── js/                    # Lógica con TypeScript/JavaScript
│   └── images/                # Recursos gráficos del panel
│
├── images/                    # Assets gráficos del proyecto
│   ├── LOGO-BUGAREPORT.png    # Logo oficial
│   ├── BugaReport-DisenoTOTAL.png
│   └── Logo-DisenoTotal.png
│
└── README.md
```

---

## Contribuir

¡Las contribuciones son bienvenidas! Por favor sigue estos pasos:

1. Haz un **fork** del repositorio
2. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Realiza tus cambios y haz commit: `git commit -m 'feat: agrega nueva funcionalidad'`
4. Sube los cambios: `git push origin feature/nueva-funcionalidad`
5. Abre un **Pull Request**

---

## Licencia

Este proyecto está bajo la licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

<div align="center">

**BugaReport** · Desarrollado con dedicación para Guadalajara de Buga

[![GitHub](https://img.shields.io/badge/GitHub-AndresGonzalezDev444-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/AndresGonzalezDev444/bugareport)

*Ciudadanos que reportan · Una ciudad que avanza*

**Guadalajara de Buga, Valle del Cauca, Colombia**

</div>
