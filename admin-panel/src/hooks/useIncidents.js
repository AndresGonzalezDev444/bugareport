import { useState, useEffect, useCallback, useRef } from 'react';
import { supabase, isSupabaseConfigured } from '../config/supabase.js';
import { MOCK_INCIDENTS } from '../utils/mockData.js';

export function useIncidents() {
  const [incidents,  setIncidents]  = useState([]);
  const [loading,    setLoading]    = useState(true);
  const [error,      setError]      = useState(null);
  const [lastUpdate, setLastUpdate] = useState(null);

  // Ref para saber si hay un fetch en curso (evita race conditions)
  const fetchingRef = useRef(false);

  const fetchIncidents = useCallback(async () => {
    // ── Modo demo (sin Supabase configurado) ─────────────────────────
    if (!isSupabaseConfigured) {
      setIncidents(MOCK_INCIDENTS);
      setLoading(false);
      setLastUpdate(new Date());
      return;
    }

    if (fetchingRef.current) return;   // evita doble fetch simultáneo
    fetchingRef.current = true;

    try {
      setLoading(true);

      // FIX 1: Intentamos primero con el JOIN completo.
      // Si falla (RLS en perfiles_ciudadanos), caemos a solo incidents.
      let data = null;
      let sbError = null;

      const joinResult = await supabase
        .from('incidents')
        .select(`
          id, user_id, category, severity, title, description,
          latitude, longitude, photo_url, status, quadrant,
          address, created_at, updated_at, admin_notes,
          perfiles_ciudadanos (
            nombre_completo, email, celular, comuna
          )
        `)
        .order('created_at', { ascending: false });

      if (!joinResult.error) {
        data     = joinResult.data;
        sbError  = null;
      } else {
        // El JOIN falló (posible RLS en perfiles_ciudadanos) — fetch sin join
        console.warn('[useIncidents] JOIN falló, reintentando sin perfil:', joinResult.error.message);
        const simpleResult = await supabase
          .from('incidents')
          .select(`
            id, user_id, category, severity, title, description,
            latitude, longitude, photo_url, status, quadrant,
            address, created_at, updated_at, admin_notes
          `)
          .order('created_at', { ascending: false });

        data    = simpleResult.data;
        sbError = simpleResult.error;
      }

      if (sbError) throw sbError;

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
      // FIX 2: NUNCA limpiar los incidentes existentes si hay un error.
      // Los incidentes que ya estaban en pantalla se mantienen.
      // (no llamamos setIncidents aquí)
    } finally {
      setLoading(false);
      fetchingRef.current = false;
    }
  }, []);

  // ── Suscripción Realtime ──────────────────────────────────────────
  // WebSocket persistente con Supabase.
  // INSERT  → el nuevo reporte del ciudadano aparece en el panel sin recargar.
  // DELETE  → se elimina del array localmente.
  // UPDATE  → se actualiza el incidente EN EL ARRAY LOCALMENTE (sin re-fetch)
  //           para evitar que un fetchIncidents() fallido vacíe la lista.
  useEffect(() => {
    fetchIncidents();
    if (!isSupabaseConfigured) return;

    const channel = supabase
      .channel('incidents-realtime')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'incidents' },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            // Nuevo reporte del ciudadano → agregar al principio
            setIncidents(prev => [{ ...payload.new, reporter: null }, ...prev]);
            setLastUpdate(new Date());

          } else if (payload.eventType === 'DELETE') {
            setIncidents(prev => prev.filter(i => i.id !== payload.old.id));
            setLastUpdate(new Date());

          } else if (payload.eventType === 'UPDATE') {
            // FIX 3: Actualizar el incidente en el array LOCAL en vez de re-fetch.
            // Esto garantiza que el incidente NUNCA desaparece cuando el admin
            // cambia el status — simplemente actualiza sus campos.
            setIncidents(prev =>
              prev.map(inc =>
                inc.id === payload.new.id
                  ? { ...inc, ...payload.new, reporter: inc.reporter }
                  : inc
              )
            );
            setLastUpdate(new Date());
          }
        }
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.log('[Realtime] Conectado — canal incidents-realtime activo');
        }
        if (status === 'CHANNEL_ERROR') {
          console.error('[Realtime] Error en el canal — reintentando...');
        }
      });

    return () => { supabase.removeChannel(channel); };
  }, [fetchIncidents]);

  // ── updateStatus ─────────────────────────────────────────────────
  // Cambia el estado → el ciudadano lo ve en tiempo real en "Mis Reportes"
  const updateStatus = useCallback(async (id, newStatus) => {
    // Actualización optimista inmediata
    setIncidents(prev =>
      prev.map(inc =>
        inc.id === id
          ? { ...inc, status: newStatus, updated_at: new Date().toISOString() }
          : inc
      )
    );

    if (!isSupabaseConfigured) return { success: true };

    const { error: sbError } = await supabase
      .from('incidents')
      .update({ status: newStatus })
      .eq('id', id);

    if (sbError) {
      // Revertir solo el incidente afectado — no limpiar todo
      console.error('[updateStatus] Error:', sbError.message);
      // Hacemos un fetch suave para restaurar ese incidente
      const { data } = await supabase
        .from('incidents')
        .select('id, status, updated_at')
        .eq('id', id)
        .single();
      if (data) {
        setIncidents(prev =>
          prev.map(inc => inc.id === id ? { ...inc, ...data } : inc)
        );
      }
      return { success: false, error: sbError.message };
    }

    return { success: true };
  }, []);

  // ── updateQuadrant ────────────────────────────────────────────────
  const updateQuadrant = useCallback(async (id, quadrant) => {
    setIncidents(prev =>
      prev.map(inc => inc.id === id ? { ...inc, quadrant } : inc)
    );

    if (!isSupabaseConfigured) return { success: true };

    const { error: sbError } = await supabase
      .from('incidents')
      .update({ quadrant })
      .eq('id', id);

    if (sbError) {
      console.error('[updateQuadrant] Error:', sbError.message);
      return { success: false, error: sbError.message };
    }
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
    isDemo:         !isSupabaseConfigured,
  };
}
