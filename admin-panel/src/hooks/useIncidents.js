import { useState, useEffect, useCallback } from 'react';
import { supabase, isSupabaseConfigured } from '../config/supabase.js';
import { MOCK_INCIDENTS } from '../utils/mockData.js';

export function useIncidents() {
  const [incidents, setIncidents]   = useState([]);
  const [loading, setLoading]       = useState(true);
  const [error, setError]           = useState(null);
  const [lastUpdate, setLastUpdate] = useState(null);

  const fetchIncidents = useCallback(async () => {
    if (!isSupabaseConfigured) {
      // Modo demo con datos mock
      setIncidents(MOCK_INCIDENTS);
      setLoading(false);
      setLastUpdate(new Date());
      return;
    }

    try {
      setLoading(true);
      const { data, error: sbError } = await supabase
        .from('incidents')
        .select(`
          id, user_id, category, severity, title, description,
          latitude, longitude, photo_url, status, quadrant,
          address, created_at, updated_at
        `)
        .order('created_at', { ascending: false });

      if (sbError) throw sbError;
      setIncidents(data || []);
      setLastUpdate(new Date());
      setError(null);
    } catch (err) {
      setError(err.message);
      // Fallback a mock data en caso de error
      setIncidents(MOCK_INCIDENTS);
    } finally {
      setLoading(false);
    }
  }, []);

  // Suscripción Realtime — refleja cambios de la app móvil en tiempo real
  useEffect(() => {
    fetchIncidents();

    if (!isSupabaseConfigured) return;

    const channel = supabase
      .channel('incidents-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'incidents' }, () => {
        fetchIncidents();
      })
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [fetchIncidents]);

  const updateStatus = useCallback(async (id, newStatus) => {
    if (!isSupabaseConfigured) {
      setIncidents(prev =>
        prev.map(inc => inc.id === id ? { ...inc, status: newStatus, updated_at: new Date().toISOString() } : inc)
      );
      return { success: true };
    }
    const { error: sbError } = await supabase
      .from('incidents')
      .update({ status: newStatus, updated_at: new Date().toISOString() })
      .eq('id', id);

    if (sbError) return { success: false, error: sbError.message };
    return { success: true };
  }, []);

  const updateQuadrant = useCallback(async (id, quadrant) => {
    if (!isSupabaseConfigured) {
      setIncidents(prev =>
        prev.map(inc => inc.id === id ? { ...inc, quadrant } : inc)
      );
      return { success: true };
    }
    const { error: sbError } = await supabase
      .from('incidents')
      .update({ quadrant, updated_at: new Date().toISOString() })
      .eq('id', id);

    if (sbError) return { success: false, error: sbError.message };
    return { success: true };
  }, []);

  return {
    incidents,
    loading,
    error,
    lastUpdate,
    refetch: fetchIncidents,
    updateStatus,
    updateQuadrant,
    isDemo: !isSupabaseConfigured,
  };
}
