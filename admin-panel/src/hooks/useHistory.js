// hooks/useHistory.js
// HU2 - Historial de seguimiento de incidentes
// Registra cada accion administrativa: cambio de estado, cuadrante, asignaciones.
// Persiste en localStorage para sobrevivir recargas de pagina.
// Si Supabase esta configurado y existe la tabla incident_history, tambien escribe alli.

import { useState, useCallback } from 'react';
import { supabase, isSupabaseConfigured } from '../config/supabase.js';

const STORAGE_KEY = 'br_incident_history';

function cargarDesdeStorage() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}');
  } catch {
    return {};
  }
}

function guardarEnStorage(data) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  } catch { /* ignore quota */ }
}

export function useHistory() {
  // Estructura: { [incidentId]: [ { id, action, oldValue, newValue, adminName, notes, createdAt } ] }
  const [history, setHistory] = useState(cargarDesdeStorage);

  /**
   * Registra una entrada de historial para un incidente.
   *
   * @param {string} incidentId
   * @param {Object} entry - { action, oldValue, newValue, adminName, notes }
   */
  const registrarAccion = useCallback(async (incidentId, {
    action,
    oldValue  = null,
    newValue  = null,
    adminName = 'Admin',
    notes     = '',
  }) => {
    const entrada = {
      id:        crypto.randomUUID ? crypto.randomUUID() : Date.now().toString(),
      action,
      oldValue,
      newValue,
      adminName,
      notes,
      createdAt: new Date().toISOString(),
    };

    setHistory(prev => {
      const actuales = prev[incidentId] || [];
      // Mas reciente primero en el array
      const updated = { ...prev, [incidentId]: [entrada, ...actuales] };
      guardarEnStorage(updated);
      return updated;
    });

    // Escritura opcional en Supabase si la tabla existe
    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('incident_history').insert({
          incident_id: incidentId,
          action,
          old_value:   oldValue  ? String(oldValue)  : null,
          new_value:   newValue  ? String(newValue)   : null,
          admin_name:  adminName,
          notes:       notes || null,
          created_at:  entrada.createdAt,
        });
      } catch {
        // Tabla puede no existir aun — ignoramos el error silenciosamente
      }
    }

    return entrada;
  }, []);

  /**
   * Obtiene el historial de un incidente especifico, ordenado de mas reciente a mas antiguo.
   */
  const getHistorial = useCallback((incidentId) => {
    return history[incidentId] || [];
  }, [history]);

  /**
   * Limpia el historial en memoria y localStorage (util para tests).
   */
  const limpiarHistorial = useCallback(() => {
    setHistory({});
    localStorage.removeItem(STORAGE_KEY);
  }, []);

  return { registrarAccion, getHistorial, limpiarHistorial };
}

