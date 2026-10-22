# PROMPT — Conexión del Panel Admin Web con la App Móvil BugaReport (Supabase)

## Contexto del proyecto

Estás trabajando en **BugaReport**, una app cívica de reportes ciudadanos para la
Alcaldía de Guadalajara de Buga, Colombia. El sistema tiene **dos frontends que
comparten el mismo backend PostgreSQL en Supabase:**

| Componente | Stack | Ruta |
|---|---|---|
| App móvil ciudadana | Flutter | `user-panel-mobile/bugareport/` |
| Panel administrativo web | React + Vite | `admin-panel/` |
| Backend compartido | Supabase (PostgreSQL + Auth + Storage + Realtime) | Proyecto en Supabase Cloud |

**Tu tarea:** Conectar el panel admin web a Supabase para que todos los datos
que el ciudadano genera desde la app móvil se vean en tiempo real en el panel.
Actualmente el panel usa `mockData.js` cuando `VITE_SUPABASE_URL` está vacío.

---

## LO QUE YA FUNCIONA EN LA APP MÓVIL (no debes cambiar nada aquí)

### Tabla principal: `incidents`
La app móvil ya escribe reportes a esta tabla con exactamente estos campos:

```sql
-- Esquema real de la tabla 'incidents' en Supabase
id           uuid PRIMARY KEY DEFAULT gen_random_uuid()
user_id      uuid REFERENCES auth.users(id)
category     text   -- valores: 'hueco_via' | 'servicios_publicos' | 'comunitario' | 'aseo_parques'
severity     text   -- valores: 'baja' | 'media' | 'alta' | 'critico'
title        text   NOT NULL
description  text
latitude     float8
longitude    float8
photo_url    text   -- URL pública en Supabase Storage (bucket: 'incident-photos')
status       text   DEFAULT 'pendiente'  -- valores: 'pendiente' | 'en_proceso' | 'resuelto'
quadrant     text   -- ej: 'Q-07' (puede ser null al crear)
address      text   -- dirección textual (puede ser null)
created_at   timestamptz DEFAULT now()
updated_at   timestamptz DEFAULT now()
```

### Metadatos EXIF guardados (validados en móvil)
La app valida en cliente que la foto tenga < 40 días de antigüedad usando
bytes EXIF. **No hay columna exif en la tabla** — solo se guarda `photo_url`.

### Autenticación móvil
- Los ciudadanos se registran/autentican con `supabase.auth` (email + password)
- El JWT se persiste automáticamente en `flutter_secure_storage`
- La tabla `incidents` tiene RLS habilitado: cada ciudadano solo lee sus propios reportes
- **El admin ve TODOS** — necesita la `service_role` key o usar anon key con política que permita lectura total para admins autenticados

### Categorías implementadas (idénticas en móvil y admin)
```
hueco_via          → 'Hueco / Vía'
servicios_publicos → 'Serv. Públicos'
comunitario        → 'Comunitario'
aseo_parques       → 'Aseo y Parques'
```

### Estados del ciclo de vida (4 fases que la app muestra al ciudadano)
```
pendiente  → Fase 1: Radicado
en_proceso → Fase 2 o 3: Asignado / En Cuadrilla  (el admin actualiza esto)
resuelto   → Fase 4: Resuelto
```
**Importante:** Cuando el admin cambia el `status` a través del panel, el
ciudadano ve el cambio en tiempo real en su pantalla "Mis Reportes" (barra de
progreso de 4 fases + chip de estado).

---

## ESTRUCTURA ACTUAL DEL PANEL ADMIN (no reescribir, solo conectar)

```
admin-panel/src/
├── config/
│   ├── supabase.js        ← cliente Supabase ya creado, solo falta llenar .env
│   └── auth.js            ← sesión local por sessionStorage + SHA-256 (mantener)
├── hooks/
│   ├── useIncidents.js    ← ya tiene fetch + Realtime + updateStatus/updateQuadrant
│   └── useAuth.js         ← autenticación local (mantener tal como está)
├── utils/
│   ├── mockData.js        ← datos demo (se ignoran cuando Supabase está configurado)
│   └── statusHelpers.js   ← labels, colores, helpers de fecha (no tocar)
├── pages/
│   ├── Dashboard.jsx      ← KPIs + mapa + lista reciente
│   ├── MapPage.jsx        ← mapa con marcadores de incidentes
│   ├── IncidentsPage.jsx  ← tabla CRUD de todos los incidentes
│   ├── MetricsPage.jsx    ← gráficos y métricas agregadas
│   └── ReportsPage.jsx    ← generación de informes PDF/CSV
└── components/
    ├── layout/            ← Layout, Sidebar, Header
    ├── incidents/         ← IncidentDrawer (panel lateral de detalle)
    ├── map/               ← MapConsole (Leaflet)
    └── ui/                ← Badge, Icons, etc.
```

### El hook `useIncidents.js` YA implementa:
1. **Fetch de todos los incidentes** desde `incidents` table (order by `created_at DESC`)
2. **Suscripción Realtime** al canal `incidents-realtime` (refleja cambios del móvil)
3. **`updateStatus(id, newStatus)`** — hace `UPDATE incidents SET status=... WHERE id=...`
4. **`updateQuadrant(id, quadrant)`** — asigna cuadrante al incidente
5. **Modo demo** — si `VITE_SUPABASE_URL` está vacío, usa `MOCK_INCIDENTS`

---

## LO QUE DEBES IMPLEMENTAR (tareas concretas)

### TAREA 1 — Configurar Supabase (.env)
Llenar el archivo `admin-panel/.env` con las credenciales del proyecto Supabase:
```env
VITE_SUPABASE_URL=https://XXXXXXXXXXXXXXXX.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
> El cliente ya está listo en `config/supabase.js` — solo faltan estas variables.

### TAREA 2 — RLS Policy para lectura admin
En Supabase Dashboard → Table Editor → `incidents` → Policies, agregar:

```sql
-- Política: el admin puede leer TODOS los reportes
-- (La anon key accede solo a lo que las políticas permiten)
CREATE POLICY "Admin puede leer todos los incidentes"
ON incidents FOR SELECT
USING (true);  -- todos los registros visibles para el rol anon (admin ya autenticado)

-- Política: el admin puede actualizar status y quadrant
CREATE POLICY "Admin puede actualizar incidentes"
ON incidents FOR UPDATE
USING (true)
WITH CHECK (true);
```

> **Alternativa segura:** Usar `service_role` key en una Edge Function para
> que la actualización del admin no quede expuesta en el frontend.

### TAREA 3 — Conectar foto en IncidentDrawer
El campo `photo_url` ya viene de la query. Mostrar la imagen del ciudadano:

```jsx
// En components/incidents/IncidentDrawer.jsx
// Donde dice "Sin foto" o tiene placeholder, reemplazar con:
{incident.photo_url ? (
  <img
    src={incident.photo_url}
    alt="Evidencia fotográfica"
    style={{ width: '100%', borderRadius: 8, objectFit: 'cover', maxHeight: 220 }}
    onError={(e) => { e.target.style.display = 'none'; }}
  />
) : (
  <div className="empty-photo">Sin evidencia fotográfica</div>
)}
```

### TAREA 4 — Mostrar user_id resuelto como email/nombre
Actualmente `incident.user_id` es un UUID. Para mostrar el email del ciudadano,
crear una tabla pública de perfiles (si no existe ya):

```sql
-- Tabla de perfiles públicos (ya puede existir — verificar)
CREATE TABLE IF NOT EXISTS profiles (
  id        uuid REFERENCES auth.users(id) PRIMARY KEY,
  full_name text,
  phone     text,
  email     text
);

-- Permitir que el admin la lea
CREATE POLICY "Admin lee perfiles"
ON profiles FOR SELECT USING (true);
```

Luego en `useIncidents.js`, hacer join:
```js
const { data } = await supabase
  .from('incidents')
  .select(`
    id, user_id, category, severity, title, description,
    latitude, longitude, photo_url, status, quadrant,
    address, created_at, updated_at,
    profiles ( full_name, email, phone )
  `)
  .order('created_at', { ascending: false });
```

### TAREA 5 — Métricas dinámicas en Dashboard.jsx
El `Dashboard.jsx` usa `calcMetrics(incidents)` que ya recibe los datos reales.
**Los KPI badges de "+12 hoy" y "5.1 hrs promedio" aún son estáticos.**
Calcularlos dinámicamente:

```js
// Calcular reportes de hoy
const hoy = incidents.filter(i => {
  const d = new Date(i.created_at);
  const ahora = new Date();
  return d.toDateString() === ahora.toDateString();
});
const reportesHoy = hoy.length;

// Calcular tiempo promedio de resolución (de en_proceso a resuelto)
// Usar updated_at - created_at para los resueltos
const resueltos = incidents.filter(i => i.status === 'resuelto');
const promedioHrs = resueltos.length > 0
  ? (resueltos.reduce((acc, i) => {
      const diff = new Date(i.updated_at) - new Date(i.created_at);
      return acc + diff;
    }, 0) / resueltos.length / 3600000).toFixed(1)
  : '—';
```

### TAREA 6 — Realtime ya implementado (verificar que funcione)
`useIncidents.js` ya suscribe al canal Realtime. Verificar en Supabase Dashboard
que **Realtime esté habilitado** para la tabla `incidents`:
- Dashboard → Database → Replication → Supacoast / Realtime → toggle `incidents` ON

### TAREA 7 — getMockMetrics actualizado para datos reales
La función `getMockMetrics` en `mockData.js` se llama como `calcMetrics(incidents)`
en `Dashboard.jsx`. Ya funciona con datos reales porque recibe el array — pero
está importada de `mockData.js`. Moverla a `statusHelpers.js` o un nuevo
`metricsHelpers.js` para mayor claridad:

```js
// utils/metricsHelpers.js  (nuevo archivo)
export function calcMetrics(incidents = []) {
  const total      = incidents.length;
  const pendientes = incidents.filter(i => i.status === 'pendiente').length;
  const enProceso  = incidents.filter(i => i.status === 'en_proceso').length;
  const resueltos  = incidents.filter(i => i.status === 'resuelto').length;
  const criticos   = incidents.filter(i => i.severity === 'critico').length;

  const byCategory = {
    hueco_via:          incidents.filter(i => i.category === 'hueco_via').length,
    servicios_publicos: incidents.filter(i => i.category === 'servicios_publicos').length,
    comunitario:        incidents.filter(i => i.category === 'comunitario').length,
    aseo_parques:       incidents.filter(i => i.category === 'aseo_parques').length,
  };

  return { total, pendientes, enProceso, resueltos, criticos, byCategory };
}
```

---

## FLUJO COMPLETO DE DATOS (cómo se conectan los dos frontends)

```
Ciudadano (Flutter App)
        │
        │  POST a tabla 'incidents' via Supabase SDK
        │  → user_id (JWT), category, severity, title, description,
        │    latitude, longitude, photo_url (Supabase Storage), status='pendiente'
        ▼
  Supabase PostgreSQL
  tabla: incidents
        │
        │  Realtime subscription (WebSocket)
        ▼
Admin Panel (React)
  useIncidents.js → fetchIncidents() → setState(data)
        │
        │  Admin cambia status: 'pendiente' → 'en_proceso' → 'resuelto'
        │  updateStatus(id, 'en_proceso')  →  UPDATE incidents SET status=...
        ▼
  Supabase PostgreSQL
        │
        │  Realtime push al móvil
        ▼
Ciudadano ve en PantallaMisReportes:
  - Barra de progreso avanza de Fase 1 a Fase 3
  - Chip de estado cambia a "En Proceso"
  - KPI "En Gestión" se incrementa en tiempo real
```

---

## RESTRICCIONES IMPORTANTES

1. **No cambiar la estructura de la tabla `incidents`** — la app móvil ya la usa en producción
2. **No cambiar `auth.js` del panel** — la sesión local con SHA-256 se mantiene
3. **No cambiar `statusHelpers.js`** — los valores de status/category/severity son los mismos que usa Flutter
4. **No usar Tailwind** — el panel usa CSS vanilla con variables en `index.css`
5. **No reemplazar `mockData.js`** — se usa como fallback cuando Supabase no está configurado
6. **Los valores de `status`** deben seguir siendo exactamente: `'pendiente'`, `'en_proceso'`, `'resuelto'`
7. **Los valores de `category`** deben seguir siendo: `'hueco_via'`, `'servicios_publicos'`, `'comunitario'`, `'aseo_parques'`
8. **Los valores de `severity`** deben seguir siendo: `'baja'`, `'media'`, `'alta'`, `'critico'`

---

## HISTORIAS DE USUARIO YA COMPLETADAS EN MÓVIL (referencia para el admin)

| HU | Feature | Relevancia para admin |
|---|---|---|
| HU1 | Registro/Login ciudadano | Admin ve `user_id` del creador |
| HU2 | Aceptación de Términos | No afecta al admin |
| HU3 | Mapa de incidentes en tiempo real | El admin tiene su propio MapPage |
| HU4 | Envío de reporte con foto | Admin ve `photo_url` + todos los campos |
| HU5 | Notificaciones locales | Solo afecta al móvil |
| HU6 | Conectividad | Solo afecta al móvil |
| HU7 | Validación EXIF (< 40 días) | Validación en cliente móvil — admin ve la foto final |
| HU8 | Autocompletado por categoría | Las mismas categorías aparecen en el admin |
| HU9 | Borradores offline | Solo en móvil (SharedPreferences) — no llegan al admin |
| HU10 | Card Borradores offline | Solo en móvil |
| HU11 | Mis Reportes ciudadano | El admin ve los mismos reportes pero todos los usuarios |
| HU12 | Línea de emergencia | Solo en móvil |
| HU13 | Persistencia sesión | Admin tiene su propia sesión (sessionStorage) |

---

## CRITERIO DE ÉXITO

El panel admin estará correctamente conectado cuando:

- [ ] Al crear un reporte desde Flutter → aparece en `Dashboard.jsx` sin recargar (Realtime)
- [ ] Al cambiar `status` desde el `IncidentDrawer` del admin → el ciudadano ve el cambio en su "Mis Reportes"
- [ ] Los KPI cards del Dashboard muestran números reales de Supabase (no los de `mockData.js`)
- [ ] El mapa (`MapPage.jsx`) muestra marcadores en las coordenadas reales de los reportes
- [ ] `ReportsPage.jsx` exporta CSV/PDF con datos reales
- [ ] `MetricsPage.jsx` calcula gráficas con los datos reales del array `incidents`
- [ ] La foto de evidencia del ciudadano se muestra en el `IncidentDrawer`
- [ ] El modo demo (`isDemo=true`) sigue funcionando si `.env` está vacío
