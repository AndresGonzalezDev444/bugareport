import { useState, useEffect, useRef } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth, AuthProvider } from './hooks/useAuth.jsx';
import { useIncidents } from './hooks/useIncidents.js';
import { useHistory }   from './hooks/useHistory.js';
import { useStaff }     from './hooks/useStaff.js';
import { useQuadrants } from './hooks/useQuadrants.js';
import { useNotifications, NOTIF_TIPOS } from './hooks/useNotifications.js';
import Layout       from './components/layout/Layout.jsx';
import Login        from './pages/Login.jsx';
import Dashboard    from './pages/Dashboard.jsx';
import MapPage      from './pages/MapPage.jsx';
import IncidentsPage from './pages/IncidentsPage.jsx';
import MetricsPage  from './pages/MetricsPage.jsx';
import ReportsPage  from './pages/ReportsPage.jsx';
import ConfigPage   from './pages/ConfigPage.jsx';
import QuadrantsPage from './pages/QuadrantsPage.jsx';
import WorkloadPage from './pages/WorkloadPage.jsx';

function ProtectedRoute({ element }) {
  const { isAuthenticated, loading } = useAuth();
  if (loading) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--color-navy)' }}>
      <span className="loading-spinner" style={{ width: 32, height: 32, borderWidth: 3 }} />
    </div>
  );
  return isAuthenticated ? element : <Navigate to="/login" replace />;
}

export default function App() {
  const { isAuthenticated, logout } = useAuth();
  const {
    incidents, loading, lastUpdate,
    refetch, updateStatus, updateQuadrant, isDemo
  } = useIncidents();

  // ── Hooks de Sprint 2 ─────────────────────────────────────────────
  const historyHook      = useHistory();
  const staffHook        = useStaff();
  const quadrantsHook    = useQuadrants();
  const notificationsHook = useNotifications();

  // ── Detectar nuevos incidentes por Realtime → notificacion ───────
  const prevIncidentsRef = useRef(null);
  useEffect(() => {
    if (!incidents || incidents.length === 0) return;
    if (prevIncidentsRef.current === null) {
      prevIncidentsRef.current = incidents.map(i => i.id);
      return;
    }
    const prevIds = new Set(prevIncidentsRef.current);
    incidents.forEach(inc => {
      if (!prevIds.has(inc.id)) {
        // Nuevo reporte del ciudadano
        notificationsHook.agregar(NOTIF_TIPOS.NUEVO_INCIDENTE, {
          incidentId: inc.id,
          titulo: 'Nuevo reporte ciudadano',
          descripcion: inc.title || 'Sin título',
        });
        if (inc.severity === 'critico') {
          notificationsHook.agregar(NOTIF_TIPOS.INCIDENTE_CRITICO, {
            incidentId: inc.id,
            titulo: 'Incidente critico detectado',
            descripcion: inc.title || 'Sin título',
          });
        }
      }
    });
    prevIncidentsRef.current = incidents.map(i => i.id);
  }, [incidents]);

  // ── Tema claro / oscuro ───────────────────────────────────────────
  const [darkMode, setDarkMode] = useState(() => {
    return localStorage.getItem('br-theme') === 'dark';
  });

  useEffect(() => {
    if (darkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
      localStorage.setItem('br-theme', 'dark');
    } else {
      document.documentElement.removeAttribute('data-theme');
      localStorage.setItem('br-theme', 'light');
    }
  }, [darkMode]);

  const toggleDark = () => setDarkMode(prev => !prev);

  // ── Props compartidos para el Layout ─────────────────────────────
  const layoutProps = {
    onLogout: logout,
    lastUpdate,
    onRefresh: refetch,
    isDemo,
    incidents,
    darkMode,
    onToggleDark: toggleDark,
    notifications:   notificationsHook.notifications,
    noLeidas:        notificationsHook.noLeidas,
    onMarcarLeida:   notificationsHook.marcarLeida,
    onMarcarTodas:   notificationsHook.marcarTodasLeidas,
    onEliminarNotif: notificationsHook.eliminar,
  };

  // ── Props del drawer (historial + personal) ───────────────────────
  const drawerProps = {
    onRegistrarAccion:   historyHook.registrarAccion,
    getHistorial:        historyHook.getHistorial,
    onAsignar:           staffHook.asignar,
    onRemoverAsignacion: staffHook.removerAsignacion,
    getAsignaciones:     staffHook.getAsignaciones,
    staff:               staffHook.staff,
    allIncidents:        incidents,
  };

  return (
    <Routes>
      {/* Ruta pública */}
      <Route
        path="/login"
        element={
          isAuthenticated
            ? <Navigate to="/" replace />
            : <Login onLoginSuccess={refetch} />
        }
      />

      {/* Rutas protegidas */}
      <Route
        path="/"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <Dashboard
                incidents={incidents}
                loading={loading}
                updateStatus={updateStatus}
                updateQuadrant={updateQuadrant}
                refetch={refetch}
                {...drawerProps}
              />
            </Layout>
          } />
        }
      />
      <Route
        path="/mapa"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <MapPage
                incidents={incidents}
                loading={loading}
                updateStatus={updateStatus}
                updateQuadrant={updateQuadrant}
                {...drawerProps}
              />
            </Layout>
          } />
        }
      />
      <Route
        path="/incidentes"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <IncidentsPage
                incidents={incidents}
                loading={loading}
                updateStatus={updateStatus}
                updateQuadrant={updateQuadrant}
                refetch={refetch}
                {...drawerProps}
              />
            </Layout>
          } />
        }
      />
      <Route
        path="/metricas"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <MetricsPage incidents={incidents} refetch={refetch} />
            </Layout>
          } />
        }
      />
      <Route
        path="/informes"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <ReportsPage incidents={incidents} />
            </Layout>
          } />
        }
      />
      <Route
        path="/cuadrantes"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <QuadrantsPage
                quadrants={quadrantsHook.quadrants}
                incidents={incidents}
                crearCuadrante={quadrantsHook.crearCuadrante}
                actualizarCuadrante={quadrantsHook.actualizarCuadrante}
                eliminarCuadrante={quadrantsHook.eliminarCuadrante}
                resetearCuadrantes={quadrantsHook.resetearCuadrantes}
              />
            </Layout>
          } />
        }
      />
      <Route
        path="/personal"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <WorkloadPage
                staff={staffHook.staff}
                assignments={staffHook.assignments}
                agregarStaff={staffHook.agregarStaff}
                desactivarStaff={staffHook.desactivarStaff}
                actualizarStaff={staffHook.actualizarStaff}
              />
            </Layout>
          } />
        }
      />
      <Route
        path="/configuracion"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <ConfigPage isDemo={isDemo} />
            </Layout>
          } />
        }
      />

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
