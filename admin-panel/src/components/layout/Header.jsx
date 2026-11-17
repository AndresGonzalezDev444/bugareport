import { useLocation } from 'react-router-dom';
import { IconBell, IconChevronRight, IconRefresh, IconSun, IconMoon } from '../ui/Icons.jsx';

const BREADCRUMBS = {
  '/':              [{ label: 'Dashboard' }],
  '/mapa':          [{ label: 'Mapa en vivo' }],
  '/incidentes':    [{ label: 'Incidentes' }],
  '/metricas':      [{ label: 'Metricas y Reportes' }],
  '/informes':      [{ label: 'Metricas y Reportes' }, { label: 'Generador de Informes Oficiales' }],
  '/configuracion': [{ label: 'Configuracion' }],
};

export default function Header({ lastUpdate, onRefresh, isDemo, darkMode, onToggleDark }) {
  const { pathname } = useLocation();
  const crumbs = BREADCRUMBS[pathname] || [{ label: 'Panel' }];

  const lastStr = lastUpdate
    ? lastUpdate.toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
    : '-';

  return (
    <header className="top-header">
      <div className="header-left">
        <img
          src="/assets/images/logo-buga-report.png"
          alt="BugaReport"
          className="header-logo"
        />
        <div className="header-divider" />
        <nav className="breadcrumb">
          {crumbs.map((crumb, i) => (
            <span key={i} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              {i > 0 && <IconChevronRight size={8} className="breadcrumb-sep" style={{ color: 'var(--color-text-muted)' }} />}
              <span className={`breadcrumb-item${i === crumbs.length - 1 ? ' active' : ''}`}>
                {crumb.label}
              </span>
            </span>
          ))}
        </nav>
      </div>

      <div className="header-right">
        {isDemo && (
          <span style={{
            background: 'var(--color-warning-light)',
            color: 'var(--color-warning)',
            padding: '4px 10px',
            borderRadius: 'var(--radius-pill)',
            fontSize: '0.625rem',
            fontWeight: 700,
            letterSpacing: '0.05em',
            textTransform: 'uppercase',
          }}>
            Modo Demo
          </span>
        )}

        <div className="live-badge">
          <span className={`live-dot${!isDemo ? ' online' : ''}`} />
          <span>{isDemo ? 'Sin conexion' : 'Activo - ' + lastStr}</span>
        </div>

        <button className="header-icon-btn" onClick={onRefresh} title="Actualizar datos">
          <IconRefresh size={14} />
        </button>

        <button className="header-icon-btn" title="Notificaciones">
          <IconBell size={14} />
          <span className="notif-dot" />
        </button>

        <button
          className={`header-icon-btn theme-toggle${darkMode ? ' dark-active' : ''}`}
          onClick={onToggleDark}
          title={darkMode ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro'}
          aria-label={darkMode ? 'Tema oscuro activo' : 'Tema claro activo'}
        >
          {darkMode ? <IconMoon size={14} /> : <IconSun size={14} />}
        </button>

        <div className="header-divider" />

        <div className="header-user-pill">
          <div>
            <div className="header-user-name">A. González</div>
            <div className="header-user-role">Supervisión Central</div>
          </div>
          <div className="header-avatar">AG</div>
        </div>
      </div>
    </header>
  );
}