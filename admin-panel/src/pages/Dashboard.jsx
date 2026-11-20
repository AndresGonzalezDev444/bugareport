import { useState } from 'react';
import MapConsole from '../components/map/MapConsole.jsx';
import IncidentDrawer from '../components/incidents/IncidentDrawer.jsx';
import { StatusBadge } from '../components/ui/Badge.jsx';
import { IconLocation, IconRefresh } from '../components/ui/Icons.jsx';
import { SEVERITY_COLOR, timeAgo, incidentId } from '../utils/statusHelpers.js';
import { calcMetrics } from '../utils/metricsHelpers.js';

function KpiCard({ label, value, sub, badge, badgeClass, accentColor, icon }) {
  return (
    <div
      className={`kpi-card${accentColor ? ' critical' : ''}`}
      style={accentColor ? { borderLeftColor: accentColor } : {}}
    >
      <div className="kpi-card-top">
        <span className="kpi-label">{label}</span>
        {icon && (
          <img src={icon} alt="" aria-hidden="true" className="kpi-card-icon" />
        )}
      </div>
      <span className="kpi-value">{value}</span>
      {badge != null && (
        <span className={`kpi-badge ${badgeClass}`}>{badge}</span>
      )}
      {sub && <div className="kpi-sub">{sub}</div>}
    </div>
  );
}

export default function Dashboard({
  incidents, loading, updateStatus, updateQuadrant, refetch,
  onRegistrarAccion, getHistorial, onAsignar, onRemoverAsignacion, getAsignaciones, staff, allIncidents,
}) {
  // Guardamos solo el ID — el objeto siempre apunta al dato mas fresco del Realtime
  const [selectedId, setSelectedId] = useState(null);
  const [mapFilter,  setMapFilter]  = useState('Cuadrantes');

  const selectedIncident = selectedId
    ? (incidents.find(i => i.id === selectedId) ?? null)
    : null;

  // Metricas 100% dinamicas desde datos reales
  const m = calcMetrics(incidents);

  const hoyBadge      = m.reportesHoy > 0  ? `+${m.reportesHoy} hoy`   : 'Sin reportes hoy';
  const criticosBadge = m.criticosHoy > 0  ? `+${m.criticosHoy} hoy`   : 'Sin criticos hoy';
  const promedioBadge = m.promedioHrs != null ? `${m.promedioHrs} hrs promedio` : 'Sin datos';

  const recent = incidents.slice(0, 8);

  return (
    <div className="page-content">
      {/* ROW 1 - KPI Cards */}
      <div className="kpi-grid">
        <KpiCard
          label="Total reportes"
          value={m.total}
          badge={hoyBadge}
          badgeClass="green"
          sub="Registrados en el sistema"
          icon="/assets/images/reportes-icon.svg"
        />
        <KpiCard
          label="Pendientes"
          value={m.pendientes}
          badge={`${m.enProceso} en proceso`}
          badgeClass="blue"
          sub="Sin validar o sin cuadrilla asignada"
          icon="/assets/images/revision-icon.svg"
        />
        <KpiCard
          label="Criticos"
          value={m.criticos}
          badge={criticosBadge}
          badgeClass="red"
          sub="Prioridad inmediata de despacho"
          icon="/assets/images/alert-icon.svg"
        />
        <KpiCard
          label="Resueltos"
          value={m.resueltos}
          badge={promedioBadge}
          badgeClass="green"
          sub="Cerrados con verificacion ciudadana"
          icon="/assets/images/resueltos-icon.svg"
        />
      </div>

      {/* ROW 2 - Mapa + Lista reciente */}
      <div className="bento-grid">
        {/* Mapa */}
        <div className="bento-col-8">
          <div className="card" style={{ overflow: 'hidden' }}>
            <div className="card-header">
              <div>
                <div className="card-title">Mapa en tiempo real - Cuadrantes Urbanos</div>
                <div className="card-subtitle">
                  Guadalajara de Buga &middot; Q-01 a Q-14 &middot; Malla vial y equipamiento
                </div>
              </div>
              <div className="map-controls">
                <div className="filter-tabs">
                  {['Cuadrantes', 'Calor', 'Marcadores'].map(f => (
                    <button
                      key={f}
                      className={`filter-tab${mapFilter === f ? ' active' : ''}`}
                      onClick={() => setMapFilter(f)}
                    >
                      {f}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {loading ? (
              <div style={{ height: 520, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <span className="loading-spinner" />
              </div>
            ) : (
              <MapConsole incidents={incidents} onSelectIncident={(inc) => setSelectedId(inc.id)} />
            )}
          </div>
        </div>

        {/* Lista reciente */}
        <div className="bento-col-4">
          <div className="card" style={{ overflow: 'hidden' }}>
            <div className="card-header" style={{ padding: '14px 16px' }}>
              <div>
                <div className="card-title" style={{ fontSize: '0.9375rem' }}>Incidentes recientes</div>
                <div className="card-subtitle">
                  {loading ? 'Cargando...' : `${incidents.length} reportes en total`}
                </div>
              </div>
              <button className="btn btn-ghost btn-icon" title="Actualizar" onClick={refetch}>
                <IconRefresh size={13} />
              </button>
            </div>

            <div className="recent-list">
              {!loading && recent.length === 0 && (
                <div className="empty-state">
                  <div className="empty-state-title">Sin incidentes</div>
                  <div className="empty-state-sub">Los reportes ciudadanos apareceran aqui en tiempo real</div>
                </div>
              )}

              {recent.map(inc => (
                <div
                  key={inc.id}
                  className={`recent-item${selectedId === inc.id ? ' selected' : ''}`}
                  onClick={() => setSelectedId(inc.id)}
                >
                  <div
                    className="recent-item-color"
                    style={{ background: SEVERITY_COLOR[inc.severity] || 'var(--color-primary)' }}
                  />
                  <div className="recent-item-info">
                    <div className="recent-item-id">{incidentId(inc.id)}</div>
                    <div className="recent-item-title">{inc.title}</div>
                    <div className="recent-item-loc">
                      <IconLocation size={9} />
                      {inc.quadrant || 'Sin cuadrante'} &middot; {inc.address?.split(',')[0] || 'Sin direcci\u00f3n'}
                    </div>
                  </div>
                  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4 }}>
                    <StatusBadge status={inc.status} />
                    <span className="recent-item-time">{timeAgo(inc.created_at)}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Drawer de detalle - se mantiene abierto al cambiar status */}
      {selectedIncident && (
        <IncidentDrawer
          incident={selectedIncident}
          onClose={() => setSelectedId(null)}
          onUpdateStatus={updateStatus}
          onUpdateQuadrant={updateQuadrant}
          onRegistrarAccion={onRegistrarAccion}
          getHistorial={getHistorial}
          onAsignar={onAsignar}
          onRemoverAsignacion={onRemoverAsignacion}
          getAsignaciones={getAsignaciones}
          staff={staff}
          allIncidents={allIncidents || incidents}
        />
      )}
    </div>
  );
}
