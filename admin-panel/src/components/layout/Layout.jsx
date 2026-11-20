import Sidebar from './Sidebar.jsx';
import Header from './Header.jsx';

export default function Layout({
  children, onLogout, lastUpdate, onRefresh, isDemo, incidents, darkMode, onToggleDark,
  notifications, noLeidas, onMarcarLeida, onMarcarTodas, onEliminarNotif,
}) {
  const pendingCount = incidents?.filter(i => i.status === 'pendiente').length || 0;

  return (
    <div className="app-shell">
      <Sidebar onLogout={onLogout} incidentCount={pendingCount} />
      <main className="main-content">
        <Header
          lastUpdate={lastUpdate}
          onRefresh={onRefresh}
          isDemo={isDemo}
          darkMode={darkMode}
          onToggleDark={onToggleDark}
          notifications={notifications}
          noLeidas={noLeidas}
          onMarcarLeida={onMarcarLeida}
          onMarcarTodas={onMarcarTodas}
          onEliminarNotif={onEliminarNotif}
        />
        {children}
      </main>
    </div>
  );
}
