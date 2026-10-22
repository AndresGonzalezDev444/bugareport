// utils/metricsHelpers.js
// Cálculos de métricas sobre datos reales de Supabase (o mock en modo demo)
// Esta función recibe el array de incidentes ya cargados — no hardcodea nada

/**
 * Calcula todas las métricas del panel a partir del array de incidentes.
 * Compatible con datos de Supabase y con mockData (fallback).
 */
export function calcMetrics(incidents = []) {
  const total      = incidents.length;
  const pendientes = incidents.filter(i => i.status === 'pendiente').length;
  const enProceso  = incidents.filter(i => i.status === 'en_proceso').length;
  const resueltos  = incidents.filter(i => i.status === 'resuelto').length;
  const criticos   = incidents.filter(i => i.severity === 'critico').length;

  // ── Distribución por categoría ──────────────────────────────────
  const byCategory = {
    hueco_via:          incidents.filter(i => i.category === 'hueco_via').length,
    servicios_publicos: incidents.filter(i => i.category === 'servicios_publicos').length,
    comunitario:        incidents.filter(i => i.category === 'comunitario').length,
    aseo_parques:       incidents.filter(i => i.category === 'aseo_parques').length,
  };

  // ── Distribución por severidad ──────────────────────────────────
  const bySeverity = {
    critico: incidents.filter(i => i.severity === 'critico').length,
    alta:    incidents.filter(i => i.severity === 'alta').length,
    media:   incidents.filter(i => i.severity === 'media').length,
    baja:    incidents.filter(i => i.severity === 'baja').length,
  };

  // ── Distribución por cuadrante ──────────────────────────────────
  const byQuadrant = {};
  incidents.forEach(i => {
    const q = i.quadrant || 'Sin asignar';
    byQuadrant[q] = (byQuadrant[q] || 0) + 1;
  });

  // ── Cuadrante más frecuente ─────────────────────────────────────
  const topQuadrantEntry = Object.entries(byQuadrant)
    .filter(([q]) => q !== 'Sin asignar')
    .sort((a, b) => b[1] - a[1])[0];
  const topQuadrant      = topQuadrantEntry?.[0] || '—';
  const topQuadrantCount = topQuadrantEntry?.[1] || 0;
  const topQuadrantPct   = total > 0 ? Math.round((topQuadrantCount / total) * 100) : 0;

  // ── Reportes de hoy ────────────────────────────────────────────
  const todayStr     = new Date().toDateString();
  const reportesHoy  = incidents.filter(i => new Date(i.created_at).toDateString() === todayStr).length;

  // ── Críticos de hoy ────────────────────────────────────────────
  const criticosHoy  = incidents.filter(
    i => i.severity === 'critico' && new Date(i.created_at).toDateString() === todayStr
  ).length;

  // ── Tiempo promedio de resolución (hrs) ─────────────────────────
  // Usa updated_at - created_at para los incidentes resueltos
  const resueltosArr = incidents.filter(i => i.status === 'resuelto');
  const promedioHrs  = resueltosArr.length > 0
    ? (
        resueltosArr.reduce((acc, i) => {
          const diff = new Date(i.updated_at) - new Date(i.created_at);
          return acc + (diff > 0 ? diff : 0);
        }, 0) / resueltosArr.length / 3_600_000
      ).toFixed(1)
    : null;

  // ── Tasa de validación: (en_proceso + resuelto) / total ─────────
  const validados       = enProceso + resueltos;
  const tasaValidacion  = total > 0
    ? Math.round((validados / total) * 100)
    : 0;

  return {
    total,
    pendientes,
    enProceso,
    resueltos,
    criticos,
    byCategory,
    bySeverity,
    byQuadrant,
    topQuadrant,
    topQuadrantCount,
    topQuadrantPct,
    reportesHoy,
    criticosHoy,
    promedioHrs,
    tasaValidacion,
    validados,
  };
}
