// hooks/useStaff.js
// HU3 - Asignacion de personal responsable
// Gestiona la lista de ingenieros y tecnicos, y las asignaciones por incidente.
// Estado local con persistencia en localStorage.

import { useState, useCallback } from 'react';

const STORAGE_KEY_STAFF       = 'br_staff';
const STORAGE_KEY_ASSIGNMENTS = 'br_assignments';

// Personal inicial por defecto (extendible desde la UI)
const STAFF_INICIAL = [
  { id: 's-001', nombre: 'Carlos Restrepo',  cargo: 'Ingeniero Civil',         especialidad: 'Vias y Pavimento',       activo: true },
  { id: 's-002', nombre: 'Diana Muñoz',      cargo: 'Ingeniera de Redes',      especialidad: 'Servicios Publicos',     activo: true },
  { id: 's-003', nombre: 'Jorge Cardona',    cargo: 'Tecnico de Campo',        especialidad: 'Bacheo y Reparacion',    activo: true },
  { id: 's-004', nombre: 'Patricia Lozano',  cargo: 'Inspectora Municipal',    especialidad: 'Control Comunitario',    activo: true },
  { id: 's-005', nombre: 'Andres Bermudez',  cargo: 'Supervisor de Cuadrilla', especialidad: 'Aseo Urbano y Parques',  activo: true },
  { id: 's-006', nombre: 'Luisa Fernandez',  cargo: 'Gestora Social',          especialidad: 'Atencion Ciudadana',     activo: true },
  { id: 's-007', nombre: 'Ricardo Torres',   cargo: 'Operario de Maquinaria',  especialidad: 'Equipo Pesado',          activo: true },
  { id: 's-008', nombre: 'Yolanda Ospina',   cargo: 'Coordinadora de Zona',    especialidad: 'Logistica y Despacho',   activo: true },
];

function cargar(key, fallback) {
  try { return JSON.parse(localStorage.getItem(key)) || fallback; }
  catch { return fallback; }
}

function guardar(key, data) {
  try { localStorage.setItem(key, JSON.stringify(data)); }
  catch { /* ignore */ }
}

export function useStaff() {
  const [staff, setStaff] = useState(() => cargar(STORAGE_KEY_STAFF, STAFF_INICIAL));
  // { [incidentId]: [{ staffId, assignedAt, assignedBy }] }
  const [assignments, setAssignments] = useState(() => cargar(STORAGE_KEY_ASSIGNMENTS, {}));

  // ── Personal disponible (activo) ─────────────────────────────
  const staffDisponible = staff.filter(s => s.activo);

  // ── Agregar miembro del personal ──────────────────────────────
  const agregarStaff = useCallback((nuevoMiembro) => {
    const miembro = {
      id:          's-' + Date.now(),
      activo:      true,
      ...nuevoMiembro,
    };
    setStaff(prev => {
      const updated = [...prev, miembro];
      guardar(STORAGE_KEY_STAFF, updated);
      return updated;
    });
    return miembro;
  }, []);

  // ── Desactivar miembro ────────────────────────────────────────
  const desactivarStaff = useCallback((staffId) => {
    setStaff(prev => {
      const updated = prev.map(s => s.id === staffId ? { ...s, activo: false } : s);
      guardar(STORAGE_KEY_STAFF, updated);
      return updated;
    });
  }, []);

  // ── Actualizar miembro (nombre, cargo, especialidad, telefono, activo) ──
  const actualizarStaff = useCallback((staffId, cambios) => {
    setStaff(prev => {
      const updated = prev.map(s => s.id === staffId ? { ...s, ...cambios } : s);
      guardar(STORAGE_KEY_STAFF, updated);
      return updated;
    });
  }, []);

  // ── Asignar miembro a incidente ───────────────────────────────
  const asignar = useCallback((incidentId, staffId, assignedBy = 'Admin') => {
    setAssignments(prev => {
      const actuales = prev[incidentId] || [];
      // Evitar duplicados
      if (actuales.some(a => a.staffId === staffId)) return prev;
      const nueva = {
        staffId,
        assignedAt: new Date().toISOString(),
        assignedBy,
      };
      const updated = { ...prev, [incidentId]: [...actuales, nueva] };
      guardar(STORAGE_KEY_ASSIGNMENTS, updated);
      return updated;
    });
  }, []);

  // ── Remover asignacion ────────────────────────────────────────
  const removerAsignacion = useCallback((incidentId, staffId) => {
    setAssignments(prev => {
      const updated = {
        ...prev,
        [incidentId]: (prev[incidentId] || []).filter(a => a.staffId !== staffId),
      };
      guardar(STORAGE_KEY_ASSIGNMENTS, updated);
      return updated;
    });
  }, []);

  // ── Obtener asignaciones de un incidente con datos del personal ─
  const getAsignaciones = useCallback((incidentId) => {
    const asigs = assignments[incidentId] || [];
    return asigs.map(a => {
      const miembro = staff.find(s => s.id === a.staffId);
      return { ...a, miembro: miembro || null };
    });
  }, [assignments, staff]);

  // ── Carga de trabajo: reportes por miembro del personal ────────
  const getCargas = useCallback(() => {
    const cargas = {};
    staff.forEach(s => { cargas[s.id] = { miembro: s, total: 0, incidentIds: [] }; });

    Object.entries(assignments).forEach(([incId, asigs]) => {
      asigs.forEach(a => {
        if (cargas[a.staffId]) {
          cargas[a.staffId].total++;
          cargas[a.staffId].incidentIds.push(incId);
        }
      });
    });

    return Object.values(cargas).sort((a, b) => b.total - a.total);
  }, [staff, assignments]);

  return {
    staff,
    staffDisponible,
    assignments,
    agregarStaff,
    desactivarStaff,
    actualizarStaff,
    asignar,
    removerAsignacion,
    getAsignaciones,
    getCargas,
  };
}

