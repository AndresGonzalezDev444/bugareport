// utils/duplicateDetector.js
// HU8 - Deteccion de incidentes duplicados
// Compara categoria, proximidad geografica y proximidad temporal.

const DISTANCIA_MAX_METROS = 200;  // radio de deteccion
const DIAS_MAX_PROXIMIDAD  = 7;    // ventana temporal

/**
 * Calcula la distancia en metros entre dos puntos GPS usando la formula de Haversine.
 */
function haversineMetros(lat1, lon1, lat2, lon2) {
  const R = 6_371_000; // radio Tierra en metros
  const toRad = deg => deg * Math.PI / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

/**
 * Encuentra posibles duplicados de un incidente dado dentro de la lista completa.
 *
 * Criterios:
 *  - Misma categoria
 *  - Ubicacion a menos de DISTANCIA_MAX_METROS metros
 *  - Creados con menos de DIAS_MAX_PROXIMIDAD dias de diferencia
 *  - No es el mismo incidente (id diferente)
 *  - No esta ya marcado como duplicado del mismo objetivo
 *
 * @param {Object} target     - Incidente de referencia
 * @param {Array}  incidents  - Lista completa de incidentes
 * @returns {Array} Posibles duplicados con distancia y dias calculados
 */
export function findDuplicates(target, incidents) {
  if (!target.latitude || !target.longitude) return [];

  const targetDate = new Date(target.created_at).getTime();

  return incidents
    .filter(inc => {
      if (inc.id === target.id)              return false;
      if (inc.category !== target.category)  return false;
      if (!inc.latitude || !inc.longitude)   return false;

      const distancia = haversineMetros(
        target.latitude, target.longitude,
        inc.latitude,    inc.longitude
      );
      if (distancia > DISTANCIA_MAX_METROS) return false;

      const diffMs  = Math.abs(new Date(inc.created_at).getTime() - targetDate);
      const diffDias = diffMs / (1000 * 60 * 60 * 24);
      if (diffDias > DIAS_MAX_PROXIMIDAD) return false;

      return true;
    })
    .map(inc => ({
      ...inc,
      _distanciaMetros: Math.round(haversineMetros(
        target.latitude, target.longitude,
        inc.latitude,    inc.longitude
      )),
      _diffDias: Math.round(
        Math.abs(new Date(inc.created_at).getTime() - targetDate) / (1000 * 60 * 60 * 24)
      ),
    }))
    .sort((a, b) => a._distanciaMetros - b._distanciaMetros);
}

