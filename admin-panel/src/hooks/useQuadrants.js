// hooks/useQuadrants.js
// HU1 - Gestion de cuadrantes geograficos
// CRUD completo de cuadrantes. Persistencia en localStorage.
// Incluye validacion de reportes activos antes de eliminar.

import { useState, useCallback } from 'react';

const STORAGE_KEY = 'br_quadrants';

// Cuadrantes iniciales Q-01 a Q-14 de Guadalajara de Buga
const CUADRANTES_INICIALES = [
  { id: 'Q-01', nombre: 'Q-01 - Centro Historico',       descripcion: 'Parque Guadalajara, Basilica, Plaza Central',      lat: 3.9001,  lon: -76.2998, radio: 400, color: '#5B0510', activo: true },
  { id: 'Q-02', nombre: 'Q-02 - Centro Ampliado',        descripcion: 'Calles 2 a 6, Carreras 10 a 16',                  lat: 3.8990,  lon: -76.2982, radio: 350, color: '#7A1E23', activo: true },
  { id: 'Q-03', nombre: 'Q-03 - Los Cristales',          descripcion: 'Barrio Los Cristales y zonas aledanas',            lat: 3.9015,  lon: -76.3008, radio: 350, color: '#2B5C8F', activo: true },
  { id: 'Q-04', nombre: 'Q-04 - La Estacion',            descripcion: 'Barrio La Estacion, Zona Ferroviaria',             lat: 3.9052,  lon: -76.3010, radio: 400, color: '#4B4ECC', activo: true },
  { id: 'Q-05', nombre: 'Q-05 - El Carmelo',             descripcion: 'Sector El Carmelo y Alrededores',                  lat: 3.8970,  lon: -76.3020, radio: 350, color: '#2E5D4B', activo: true },
  { id: 'Q-06', nombre: 'Q-06 - San Pedro',              descripcion: 'Barrio San Pedro, sector residencial',             lat: 3.9030,  lon: -76.3050, radio: 300, color: '#86521B', activo: true },
  { id: 'Q-07', nombre: 'Q-07 - El Albergue',            descripcion: 'Barrio El Albergue, Cra 12 zona vial',             lat: 3.9032,  lon: -76.3034, radio: 400, color: '#5B0510', activo: true },
  { id: 'Q-08', nombre: 'Q-08 - El Molino',              descripcion: 'Sector El Molino, zona comercial e industrial',    lat: 3.9044,  lon: -76.3019, radio: 350, color: '#2B5C8F', activo: true },
  { id: 'Q-09', nombre: 'Q-09 - Alfonso Lopez',          descripcion: 'Barrio Alfonso Lopez, sector residencial',         lat: 3.9067,  lon: -76.3045, radio: 400, color: '#7A1E23', activo: true },
  { id: 'Q-10', nombre: 'Q-10 - Versalles',              descripcion: 'Sector Versalles, zona nororiental',               lat: 3.9080,  lon: -76.3010, radio: 350, color: '#4B4ECC', activo: true },
  { id: 'Q-11', nombre: 'Q-11 - Av. Colombia',           descripcion: 'Avenida Colombia, zona de acceso occidental',      lat: 3.9080,  lon: -76.3060, radio: 500, color: '#2E5D4B', activo: true },
  { id: 'Q-12', nombre: 'Q-12 - Industrial Norte',       descripcion: 'Zona industrial norte, bodegas y fabricas',        lat: 3.9100,  lon: -76.2980, radio: 450, color: '#86521B', activo: true },
  { id: 'Q-13', nombre: 'Q-13 - Sur Residencial',        descripcion: 'Sector residencial sur, urbanizaciones',           lat: 3.8950,  lon: -76.2970, radio: 400, color: '#5B0510', activo: true },
  { id: 'Q-14', nombre: 'Q-14 - Periferia Occidental',   descripcion: 'Zona periferica occidental, via al mar',           lat: 3.8960,  lon: -76.3080, radio: 500, color: '#2B5C8F', activo: true },
];

function cargar() {
  try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || CUADRANTES_INICIALES; }
  catch { return CUADRANTES_INICIALES; }
}

function guardar(data) {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(data)); }
  catch { /* ignore */ }
}

export function useQuadrants() {
  const [quadrants, setQuadrants] = useState(cargar);

  // ── Crear cuadrante ───────────────────────────────────────────
  const crearCuadrante = useCallback((datos) => {
    const nuevo = {
      id:          datos.id || 'Q-' + String(Date.now()).slice(-3),
      nombre:      datos.nombre,
      descripcion: datos.descripcion || '',
      lat:         parseFloat(datos.lat) || 3.9001,
      lon:         parseFloat(datos.lon) || -76.3000,
      radio:       parseInt(datos.radio, 10) || 300,
      color:       datos.color || '#5B0510',
      activo:      true,
    };
    setQuadrants(prev => {
      const updated = [...prev, nuevo];
      guardar(updated);
      return updated;
    });
    return nuevo;
  }, []);

  // ── Actualizar cuadrante ──────────────────────────────────────
  const actualizarCuadrante = useCallback((id, cambios) => {
    setQuadrants(prev => {
      const updated = prev.map(q => q.id === id ? { ...q, ...cambios } : q);
      guardar(updated);
      return updated;
    });
  }, []);

  // ── Eliminar cuadrante (solo si no tiene reportes activos) ────
  const eliminarCuadrante = useCallback((id, incidents = []) => {
    const reportesActivos = incidents.filter(
      inc => inc.quadrant === id && inc.status !== 'resuelto'
    );
    if (reportesActivos.length > 0) {
      return {
        ok:      false,
        mensaje: `No se puede eliminar: tiene ${reportesActivos.length} reporte${reportesActivos.length > 1 ? 's' : ''} activo${reportesActivos.length > 1 ? 's' : ''} asignado${reportesActivos.length > 1 ? 's' : ''}.`,
      };
    }
    setQuadrants(prev => {
      const updated = prev.filter(q => q.id !== id);
      guardar(updated);
      return updated;
    });
    return { ok: true };
  }, []);

  // ── Resetear a valores por defecto ───────────────────────────
  const resetearCuadrantes = useCallback(() => {
    setQuadrants(CUADRANTES_INICIALES);
    guardar(CUADRANTES_INICIALES);
  }, []);

  return {
    quadrants,
    crearCuadrante,
    actualizarCuadrante,
    eliminarCuadrante,
    resetearCuadrantes,
  };
}

