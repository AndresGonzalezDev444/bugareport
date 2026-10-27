import { useState } from 'react';
import MapConsole from '../components/map/MapConsole.jsx';
import IncidentDrawer from '../components/incidents/IncidentDrawer.jsx';
import { StatusBadge } from '../components/ui/Badge.jsx';
import { IconLocation, IconRefresh, IconMap } from '../components/ui/Icons.jsx';
import { SEVERITY_COLOR, timeAgo, incidentId } from '../utils/statusHelpers.js';
import { calcMetrics } from '../utils/metricsHelpers.js';

function KpiCard({ label, value, valueClass, sub, badge, badgeClass, accentColor, bars }) {
  return (
    <div
      className={`kpi-card${accentColor ? ' critical' : ''}`}
      style={accentColor ? { borderLeftColor: accentColor } : {}}
    >
      <div className="kpi-card-top">
        <span className="kpi-label">{label}</span>
        {badge != null && (
          <span className={`kpi-badge ${badgeClass}`}>{badge}</span>
        )}
      </div>
      <div style={{ position: 'relative', height: 70, display: 'flex', alignItems: 'flex-end' }}>
        <span className={`kpi-value ${valueClass || ''}`}>{value}</span>
        {bars && (
          <div className="kpi-bar-container">
            {bars.map((h, i) => (
              <div
                key={i}
                className="kpi-bar"
                style={{ height: `${h}%`, background: accentColor || 'var(--color-success)' }}
              />
            ))}
          </div>
        )}
      </div>
      {sub && <div className="kpi-sub">{sub}</div>}
    </div>
  );
}

export default function Dashboard({ incidents, loading, updateStatus, updateQuadrant, refetch }) {
  const [selectedIncident, setSelectedIncident] = useState(null);
  const [mapFilter,        setMapFilter]        = useState('Cuadrantes');

  // Métricas 100% dinámicas desde datos reales
  const m = calcMetrics(incidents);

  // Badge de "reportes hoy"
  const hoyBadge = m.reportesHoy > 0 ? `+${m.reportesHoy} hoy` : 'Sin reportes hoy';

  // Badge de "críticos hoy"
  const criticosBadge = m.criticosHoy > 0 ? `+${m.criticosHoy} hoy` : 'Sin críticos hoy';

  // Badge de "promedio de resolución"
  const promedioBadge = m.promedioHrs != null ? `${m.promedioHrs} hrs promedio` : 'Sin datos';

  const recent = incidents.slice(0, 8);

  return (
    <div className="page-content">
      {/* ROW 1 — KPI Cards */}
      <div className="kpi-grid">
        <KpiCard
          label="Total reportes"
          value={m.total}
          badge={hoyBadge}
          badgeClass="green"
          sub="Registrados en el sistema"
          bars={[30, 45, 60, 50, 80, 70, 100]}
          valueClass=""
        />
        <KpiCard
          label="Pendientes"
          value={m.pendientes}
          badge={`${m.enProceso} en proceso`}
          badgeClass="blue"
          sub="Sin validar o sin cuadrilla asignada"
          bars={[60, 50, 70, 55, 65, 60, 75]}
          valueClass="orange"
        />
        <KpiCard
          label="Críticos"
          value={m.criticos}
          badge={criticosBadge}
          badgeClass="red"
          sub="Prioridad inmediata de despacho"
          bars={[40, 55, 50, 70, 65, 80, 85]}
          accentColor="var(--color-primary-muted)"
          valueClass="red"
        />
        <KpiCard
          label="Resueltos"
          value={m.resueltos}
          badge={promedioBadge}
          badgeClass="green"
          sub="Cerrados con verificación ciudadana"
          bars={[50, 65, 75, 80, 85, 90, 95]}
          valueClass="green"
        />
      </div>

      {/* ROW 2 — Mapa + Lista reciente */}
      <div className="bento-grid">
        {/* Mapa */}
        <div className="bento-col-8">
          <div className="card" style={{ overflow: 'hidden' }}>
            <div className="card-header">
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <div style={{
                  background: 'var(--color-navy)', borderRadius: 8,
                  padding: '8px 8px 13px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <IconMap size={14} style={{ color: 'var(--bg-header)' }} />
                </div>
                <div>
                  <div className="card-title">Mapa en tiempo real — Cuadrantes Urbanos</div>
                  <div className="card-subtitle">
                    Guadalajara de Buga · Q-01 a Q-14 · Malla vial y equipamiento
                  </div>
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
              <MapConsole incidents={incidents} onSelectIncident={setSelectedIncident} />
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
                  <div className="empty-state-sub">Los reportes ciudadanos aparecerán aquí en tiempo real</div>
                </div>
              )}

              {recent.map(inc => (
                <div
                  key={inc.id}
                  className="recent-item"
                  onClick={() => setSelectedIncident(inc)}
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
                      {inc.quadrant || '—'} · {inc.address?.split(',')[0] || '—'}
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

      {/* Drawer de detalle */}
      {selectedIncident && (
        <IncidentDrawer
          incident={selectedIncident}
          onClose={() => setSelectedIncident(null)}
          onUpdateStatus={updateStatus}
          onUpdateQuadrant={updateQuadrant}
        />
      )}
    </div>
  );
}
