import { NavLink, useNavigate } from 'react-router-dom';
import {
  IconDashboard, IconMap, IconList, IconChart,
  IconReport, IconLogout, IconSettings
} from '../ui/Icons.jsx';

const NAV_ITEMS = [
  { to: '/',          label: 'Dashboard',     Icon: IconDashboard },
  { to: '/mapa',      label: 'Mapa en vivo',  Icon: IconMap },
  { to: '/incidentes',label: 'Incidentes',    Icon: IconList,   badge: null },
  { to: '/metricas',  label: 'Métricas',      Icon: IconChart },
  { to: '/informes',  label: 'Informes',      Icon: IconReport },
];

export default function Sidebar({ onLogout, incidentCount }) {
  const navigate = useNavigate();

  function handleLogout() {
    onLogout();
    navigate('/login');
  }

  return (
    <aside className="sidebar">
      {/* Brand */}
      <div className="sidebar-brand">
        <img
          src="/assets/images/logo-buga-report.png"
          alt="BugaReport"
          className="sidebar-logo"
        />
        <div>
          <div className="sidebar-brand-text">BugaReport</div>
          <div className="sidebar-brand-sub">Civic Console</div>
        </div>
      </div>

      {/* Navegación */}
      <div className="sidebar-section-label">Principal</div>
      <nav className="sidebar-nav">
        {NAV_ITEMS.map(({ to, label, Icon, badge }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            className={({ isActive }) => `nav-item${isActive ? ' active' : ''}`}
          >
            <Icon size={16} className="nav-item-icon" />
            <span>{label}</span>
            {label === 'Incidentes' && incidentCount > 0 && (
              <span className="nav-badge">{incidentCount > 99 ? '99+' : incidentCount}</span>
            )}
          </NavLink>
        ))}

        <div className="sidebar-section-label" style={{ marginTop: 16 }}>Sistema</div>

        <NavLink
          to="/configuracion"
          className={({ isActive }) => `nav-item${isActive ? ' active' : ''}`}
        >
          <IconSettings size={16} className="nav-item-icon" />
          <span>Configuración</span>
        </NavLink>
      </nav>

      {/* Footer / usuario */}
      <div className="sidebar-footer">
        <div className="sidebar-user" onClick={handleLogout} role="button" title="Cerrar sesión">
          <div className="sidebar-avatar">AG</div>
          <div className="sidebar-user-info">
            <div className="sidebar-user-name">A. González</div>
            <div className="sidebar-user-role">Admin · Cerrar sesión</div>
          </div>
          <IconLogout size={14} style={{ color: 'rgba(255,255,255,0.3)', flexShrink: 0 }} />
        </div>
      </div>
    </aside>
  );
}
