// utils/queryService.js
// HU11 - Servicio de consulta de incidentes para exportacion
// Aplica filtros sobre los incidentes ya cargados y devuelve estructura
// compatible con CSV y PDF.

/**
 * Aplica filtros sobre el array de incidentes ya cargados.
 * Todos los parametros son opcionales — sin filtro = todos los datos.
 *
 * @param {Array}  incidents  - Array de incidentes completos
 * @param {Object} filters    - { categoria, estado, cuadrante, fechaDesde, fechaHasta }
 * @returns {Array} Registros filtrados listos para exportar
 */
export function queryIncidents(incidents = [], filters = {}) {
  const { categoria, estado, cuadrante, fechaDesde, fechaHasta } = filters;

  return incidents.filter(inc => {
    if (categoria && inc.category !== categoria) return false;
    if (estado    && inc.status   !== estado)    return false;
    if (cuadrante && inc.quadrant !== cuadrante) return false;

    if (fechaDesde) {
      const desde = new Date(fechaDesde);
      desde.setHours(0, 0, 0, 0);
      if (new Date(inc.created_at) < desde) return false;
    }

    if (fechaHasta) {
      const hasta = new Date(fechaHasta);
      hasta.setHours(23, 59, 59, 999);
      if (new Date(inc.created_at) > hasta) return false;
    }

    return true;
  });
}

/**
 * Convierte un array de incidentes en filas CSV-ready.
 * Incluye todos los campos requeridos por el criterio de aceptacion:
 * fecha, categoria, ubicacion y estado del incidente.
 *
 * @param {Array} incidents
 * @returns {Array<Array>} Filas con encabezado como primera fila
 */
export function toCSVRows(incidents) {
  const header = [
    'ID', 'Titulo', 'Categoria', 'Severidad', 'Estado',
    'Cuadrante', 'Direccion', 'Latitud', 'Longitud', 'Fecha',
  ];

  const rows = incidents.map(inc => [
    'REP-' + (inc.id?.slice(0, 4).toUpperCase() ?? '????'),
    inc.title      ?? '',
    inc.category   ?? '',
    inc.severity   ?? '',
    inc.status     ?? '',
    inc.quadrant   ?? '',
    inc.address    ?? '',
    inc.latitude   ?? '',
    inc.longitude  ?? '',
    inc.created_at ? new Date(inc.created_at).toLocaleString('es-CO') : '',
  ]);

  return [header, ...rows];
}

/**
 * Convierte un array de incidentes en objetos planos para PDF.
 *
 * @param {Array} incidents
 * @returns {Array<Object>}
 */
export function toPDFData(incidents) {
  return incidents.map(inc => ({
    id:        'REP-' + (inc.id?.slice(0, 4).toUpperCase() ?? '????'),
    titulo:    inc.title      ?? '—',
    categoria: inc.category   ?? '—',
    severidad: inc.severity   ?? '—',
    estado:    inc.status     ?? '—',
    cuadrante: inc.quadrant   ?? '—',
    direccion: inc.address    ?? '—',
    gps:       `${inc.latitude?.toFixed(5) ?? '—'}, ${inc.longitude?.toFixed(5) ?? '—'}`,
    fecha:     inc.created_at ? new Date(inc.created_at).toLocaleString('es-CO') : '—',
  }));
}

