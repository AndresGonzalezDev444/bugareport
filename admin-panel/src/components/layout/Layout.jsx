import Sidebar from './Sidebar.jsx';
import Header from './Header.jsx';

export default function Layout({ children, onLogout, lastUpdate, onRefresh, isDemo, incidents }) {
  const pendingCount = incidents?.filter(i => i.status === 'pendiente').length || 0;

  return (
    <div className="app-shell">
      <Sidebar onLogout={onLogout} incidentCount={pendingCount} />
      <main className="main-content">
        <Header lastUpdate={lastUpdate} onRefresh={onRefresh} isDemo={isDemo} />
        {children}
      </main>
    </div>
  );
}
