// hooks/useNotifications.js
// HU10 - Gestion de notificaciones administrativas
// Intercepta eventos Realtime de useIncidents para generar notificaciones.
// Las notificaciones persisten en localStorage durante la sesion.

import { useState, useCallback } from 'react';

const STORAGE_KEY = 'br_notifications';
const MAX_NOTIFS  = 50; // maximo de notificaciones en memoria

function cargar() {
  try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || []; }
  catch { return []; }
}

function guardar(data) {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(data.slice(0, MAX_NOTIFS))); }
  catch { /* ignore */ }
}

/**
 * Tipos de evento y sus etiquetas.
 */
export const NOTIF_TIPOS = {
  NUEVO_INCIDENTE:    'nuevo_incidente',
  ESTADO_CAMBIADO:    'estado_cambiado',
  INCIDENTE_CRITICO:  'incidente_critico',
  CUADRANTE_ASIGNADO: 'cuadrante_asignado',
  PERSONAL_ASIGNADO:  'personal_asignado',
};

export const NOTIF_LABELS = {
  nuevo_incidente:    'Nuevo reporte',
  estado_cambiado:    'Estado actualizado',
  incidente_critico:  'Incidente critico',
  cuadrante_asignado: 'Cuadrante asignado',
  personal_asignado:  'Personal asignado',
};

export function useNotifications() {
  const [notifications, setNotifications] = useState(cargar);

  const noLeidas = notifications.filter(n => !n.leida).length;

  // ── Agregar notificacion ──────────────────────────────────────
  const agregar = useCallback((tipo, { incidentId, titulo, descripcion }) => {
    const notif = {
      id:          crypto.randomUUID ? crypto.randomUUID() : Date.now().toString(),
      tipo,
      incidentId:  incidentId || null,
      titulo:      titulo     || NOTIF_LABELS[tipo] || 'Notificacion',
      descripcion: descripcion || '',
      leida:       false,
      createdAt:   new Date().toISOString(),
    };

    setNotifications(prev => {
      const updated = [notif, ...prev].slice(0, MAX_NOTIFS);
      guardar(updated);
      return updated;
    });

    return notif;
  }, []);

  // ── Marcar como leida ─────────────────────────────────────────
  const marcarLeida = useCallback((id) => {
    setNotifications(prev => {
      const updated = prev.map(n => n.id === id ? { ...n, leida: true } : n);
      guardar(updated);
      return updated;
    });
  }, []);

  // ── Marcar todas como leidas ──────────────────────────────────
  const marcarTodasLeidas = useCallback(() => {
    setNotifications(prev => {
      const updated = prev.map(n => ({ ...n, leida: true }));
      guardar(updated);
      return updated;
    });
  }, []);

  // ── Eliminar notificacion ─────────────────────────────────────
  const eliminar = useCallback((id) => {
    setNotifications(prev => {
      const updated = prev.filter(n => n.id !== id);
      guardar(updated);
      return updated;
    });
  }, []);

  // ── Limpiar todas ─────────────────────────────────────────────
  const limpiarTodas = useCallback(() => {
    setNotifications([]);
    localStorage.removeItem(STORAGE_KEY);
  }, []);

  return {
    notifications,
    noLeidas,
    agregar,
    marcarLeida,
    marcarTodasLeidas,
    eliminar,
    limpiarTodas,
  };
}

