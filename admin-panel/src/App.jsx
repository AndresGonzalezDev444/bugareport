import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './hooks/useAuth.js';
import { useIncidents } from './hooks/useIncidents.js';
import Layout from './components/layout/Layout.jsx';
import Login from './pages/Login.jsx';
import Dashboard from './pages/Dashboard.jsx';
import MapPage from './pages/MapPage.jsx';
import IncidentsPage from './pages/IncidentsPage.jsx';
import MetricsPage from './pages/MetricsPage.jsx';
import ReportsPage from './pages/ReportsPage.jsx';

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
    refetch, updateStatus, isDemo
  } = useIncidents();

  const layoutProps = {
    onLogout: logout,
    lastUpdate,
    onRefresh: refetch,
    isDemo,
    incidents,
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
              <Dashboard incidents={incidents} loading={loading} updateStatus={updateStatus} />
            </Layout>
          } />
        }
      />
      <Route
        path="/mapa"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <MapPage incidents={incidents} loading={loading} updateStatus={updateStatus} />
            </Layout>
          } />
        }
      />
      <Route
        path="/incidentes"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <IncidentsPage incidents={incidents} loading={loading} updateStatus={updateStatus} refetch={refetch} />
            </Layout>
          } />
        }
      />
      <Route
        path="/metricas"
        element={
          <ProtectedRoute element={
            <Layout {...layoutProps}>
              <MetricsPage incidents={incidents} />
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

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
