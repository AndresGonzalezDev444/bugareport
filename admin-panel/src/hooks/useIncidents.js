import { useState, useEffect, useCallback } from 'react';
import { supabase, isSupabaseConfigured } from '../config/supabase.js';
import { MOCK_INCIDENTS } from '../utils/mockData.js';

export function useIncidents() {
  const [incidents,   setIncidents]   = useState([]);
  const [loading,     setLoading]     = useState(true);
  const [error,       setError]       = useState(null);
  const [lastUpdate,  setLastUpdate]  = useState(null);

  const fetchIncidents = useCallback(async () => {
    // ── Modo demo: sin Supabase configurado ──────────────────────
    if (!isSupabaseConfigured) {
      setIncidents(MOCK_INCIDENTS);
      setLoading(false);
      setLastUpdate(new Date());
      return;
    }

    try {
      setLoading(true);

      // JOIN con perfiles_ciudadanos para mostrar nombre/email del reportante
      // La política "Incidents are publicly viewable" (USING true) permite leer todos
      // La política "Admins ven todos los perfiles" cubre el join
      const { data, error: sbError } = await supabase
        .from('incidents')
        .select(`
          id,
          user_id,
          category,
          severity,
          title,
          description,
          latitude,
          longitude,
          photo_url,
          status,
          quadrant,
          address,
          created_at,
          updated_at,
          perfiles_ciudadanos (
            nombre_completo,
            email,
            celular,
            comuna
          )
        `)
        .order('created_at', { ascending: false });

      if (sbError) throw sbError;

      // Normalizar: añadir campo `reporter` con datos del ciudadano
      const normalized = (data || []).map(inc => ({
        ...inc,
        reporter: inc.perfiles_ciudadanos || null,
      }));

      setIncidents(normalized);
      setLastUpdate(new Date());
      setError(null);
    } catch (err) {
      console.error('[useIncidents] Error al cargar incidentes:', err.message);
      setError(err.message);
      // Fallback a mock en caso de error de red o RLS
      setIncidents(MOCK_INCIDENTS);
    } finally {
      setLoading(false);
    }
  }, []);

  // ── Suscripción Realtime ────────────────────────────────────────
  // Escucha INSERT, UPDATE, DELETE en la tabla incidents
  // Cuando el ciudadano crea un reporte desde Flutter → aparece aquí sin recargar
  // Cuando el admin cambia status → el canal también notifica al móvil
  useEffect(() => {
    fetchIncidents();

    if (!isSupabaseConfigured) return;

    const channel = supabase
      .channel('incidents-realtime')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'incidents' },
        (payload) => {
          // Optimistic update para INSERT y DELETE sin re-fetch completo
          if (payload.eventType === 'INSERT') {
            setIncidents(prev => [{ ...payload.new, reporter: null }, ...prev]);
            setLastUpdate(new Date());
          } else if (payload.eventType === 'DELETE') {
            setIncidents(prev => prev.filter(i => i.id !== payload.old.id));
            setLastUpdate(new Date());
          } else {
            // UPDATE: re-fetch para incluir datos del join
            fetchIncidents();
          }
        }
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.log('[Realtime] Conectado al canal incidents-realtime');
        }
      });

    return () => { supabase.removeChannel(channel); };
  }, [fetchIncidents]);

  // ── updateStatus ───────────────────────────────────────────────
  // Cambia el estado de un incidente → el ciudadano lo ve en tiempo real en "Mis Reportes"
  const updateStatus = useCallback(async (id, newStatus) => {
    if (!isSupabaseConfigured) {
      setIncidents(prev =>
        prev.map(inc =>
          inc.id === id
            ? { ...inc, status: newStatus, updated_at: new Date().toISOString() }
            : inc
        )
      );
      return { success: true };
    }

    // Optimistic UI: actualizar localmente antes de confirmar con Supabase
    setIncidents(prev =>
      prev.map(inc =>
        inc.id === id
          ? { ...inc, status: newStatus, updated_at: new Date().toISOString() }
          : inc
      )
    );

    const { error: sbError } = await supabase
      .from('incidents')
      .update({ status: newStatus })
      .eq('id', id);

    if (sbError) {
      // Revertir si falla
      console.error('[updateStatus] Error:', sbError.message);
      fetchIncidents();
      return { success: false, error: sbError.message };
    }

    return { success: true };
  }, [fetchIncidents]);

  // ── updateQuadrant ─────────────────────────────────────────────
  const updateQuadrant = useCallback(async (id, quadrant) => {
    if (!isSupabaseConfigured) {
      setIncidents(prev =>
        prev.map(inc => inc.id === id ? { ...inc, quadrant } : inc)
      );
      return { success: true };
    }

    setIncidents(prev =>
      prev.map(inc => inc.id === id ? { ...inc, quadrant } : inc)
    );

    const { error: sbError } = await supabase
      .from('incidents')
      .update({ quadrant })
      .eq('id', id);

    if (sbError) {
      console.error('[updateQuadrant] Error:', sbError.message);
      fetchIncidents();
      return { success: false, error: sbError.message };
    }

    return { success: true };
  }, [fetchIncidents]);

  // ── addResponse (futuro: fase 2 backend) ──────────────────────
  // Permite que el admin deje una respuesta visible al ciudadano
  const addResponse = useCallback(async (incidentId, responseText) => {
    if (!isSupabaseConfigured) return { success: true };

    // Tabla incident_responses — se crea en fase 2
    // Por ahora actualiza un campo notes si existe
    const { error: sbError } = await supabase
      .from('incidents')
      .update({ admin_notes: responseText })
      .eq('id', incidentId);

    if (sbError) return { success: false, error: sbError.message };
    return { success: true };
  }, []);

  return {
    incidents,
    loading,
    error,
    lastUpdate,
    refetch:        fetchIncidents,
    updateStatus,
    updateQuadrant,
    addResponse,
    isDemo:         !isSupabaseConfigured,
  };
}
