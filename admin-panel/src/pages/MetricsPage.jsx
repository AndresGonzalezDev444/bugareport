import { useMemo, useState } from 'react';
import {
  Chart as ChartJS, ArcElement, Tooltip, Legend,
  CategoryScale, LinearScale, BarElement, Title,
} from 'chart.js';
import { Doughnut, Bar } from 'react-chartjs-2';
import { CATEGORY_LABELS, CATEGORY_COLOR, SEVERITY_COLOR } from '../utils/statusHelpers.js';
import { calcMetrics } from '../utils/metricsHelpers.js';

ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title);

const TABS = ['Resumen General', 'Por categoría', 'Por severidad', 'Tiempos SLA', 'Distribución Cuadrantes'];

function MetricCard({ label, value, sub, accentColor, badge }) {
  return (
    <div className="card" style={{ padding: 20 }}>
      <div style={{ fontSize: '0.6875rem', fontWeight: 700, letterSpacing: '0.05em', textTransform: 'uppercase', color: 'var(--color-text-muted)', marginBottom: 8 }}>
        {label}
      </div>
      <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1.75rem', color: accentColor || 'var(--color-navy)', lineHeight: 1.2, marginBottom: 6 }}>
        {value}
      </div>
      {badge && (
        <span style={{ display: 'inline-block', background: 'var(--color-success-lighter)', color: 'var(--color-success)', padding: '2px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.6875rem', fontWeight: 600, marginBottom: 6 }}>
          {badge}
        </span>
      )}
      {sub && <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>{sub}</div>}
    </div>
  );
}

export default function MetricsPage({ incidents, refetch }) {
  const [activeTab,   setActiveTab]   = useState('Resumen General');
  const [periodoDesde, setPeriodoDesde] = useState('');
  const [periodoHasta, setPeriodoHasta] = useState('');
  const [filtroSector, setFiltroSector] = useState('');
  const [filtroEstado, setFiltroEstado] = useState('');

  // Filtrar incidents por periodo, sector y estado
  const incidentesFiltrados = useMemo(() => {
    let result = incidents || [];
    if (periodoDesde) result = result.filter(i => new Date(i.created_at) >= new Date(periodoDesde + 'T00:00:00'));
    if (periodoHasta) result = result.filter(i => new Date(i.created_at) <= new Date(periodoHasta + 'T23:59:59'));
    if (filtroSector) result = result.filter(i => i.quadrant === filtroSector);
    if (filtroEstado) result = result.filter(i => i.status  === filtroEstado);
    return result;
  }, [incidents, periodoDesde, periodoHasta, filtroSector, filtroEstado]);

  const m = useMemo(() => calcMetrics(incidentesFiltrados), [incidentesFiltrados]);

  const hayFiltros = periodoDesde || periodoHasta || filtroSector || filtroEstado;
  function limpiarFiltros() {
    setPeriodoDesde(''); setPeriodoHasta('');
    setFiltroSector(''); setFiltroEstado('');
  }

  // Chart data
  const donutData = {
    labels: Object.keys(m.byCategory).map(k => CATEGORY_LABELS[k] || k),
    datasets: [{
      data:             Object.values(m.byCategory),
      backgroundColor:  Object.keys(m.byCategory).map(k => CATEGORY_COLOR[k]),
      borderWidth:      3,
      borderColor:      '#FFFFFF',
      hoverBorderWidth: 4,
    }],
  };

  const donutOpts = {
    responsive: true,
    maintainAspectRatio: true,
    cutout: '68%',
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: {
          label: ctx => ` ${ctx.label}: ${ctx.parsed} reportes (${m.total > 0 ? Math.round(ctx.parsed / m.total * 100) : 0}%)`,
        },
      },
    },
  };

  const barData = {
    labels: ['Crítico', 'Alta', 'Media', 'Baja'],
    datasets: [{
      label:           'Incidentes',
      data:            [m.bySeverity.critico, m.bySeverity.alta, m.bySeverity.media, m.bySeverity.baja],
      backgroundColor: [SEVERITY_COLOR.critico, SEVERITY_COLOR.alta, SEVERITY_COLOR.media, SEVERITY_COLOR.baja],
      borderRadius:    6,
      borderSkipped:   false,
    }],
  };

  const barOpts = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { grid: { display: false }, border: { display: false } },
      y: { grid: { color: 'rgba(221,192,190,0.15)' }, border: { display: false }, ticks: { precision: 0 } },
    },
  };

  const quadrantEntries = Object.entries(m.byQuadrant).sort((a, b) => b[1] - a[1]).slice(0, 8);
  const quadrantData = {
    labels: quadrantEntries.map(([q]) => q),
    datasets: [{
      label:           'Reportes',
      data:            quadrantEntries.map(([, n]) => n),
      backgroundColor: 'rgba(91, 5, 16, 0.75)',
      borderRadius:    5,
      borderSkipped:   false,
    }],
  };

  // Cuadrantes disponibles para filtro
  const cuadrantesDisponibles = Object.keys(m.byQuadrant).filter(q => q !== 'Sin asignar').sort();

  return (
    <>
      <div className="page-sub-header">
        <div className="page-heading">
          <h1>Métricas y Reportes</h1>
          <div className="page-heading-sub">Análisis operativo de incidentes ciudadanos — datos en tiempo real</div>
        </div>
        <div className="page-actions" style={{ flexWrap: 'wrap', gap: 8 }}>
          {/* Filtros de periodo */}
          <input
            type="date"
            value={periodoDesde}
            onChange={e => setPeriodoDesde(e.target.value)}
            className="select-filter"
            title="Desde"
            style={{ fontSize: '0.8rem' }}
          />
          <input
            type="date"
            value={periodoHasta}
            onChange={e => setPeriodoHasta(e.target.value)}
            className="select-filter"
            title="Hasta"
            style={{ fontSize: '0.8rem' }}
          />
          <select
            className="select-filter"
            value={filtroSector}
            onChange={e => setFiltroSector(e.target.value)}
          >
            <option value="">Sector: Todos los cuadrantes</option>
            {cuadrantesDisponibles.map(q => <option key={q} value={q}>{q}</option>)}
          </select>
          <select
            className="select-filter"
            value={filtroEstado}
            onChange={e => setFiltroEstado(e.target.value)}
          >
            <option value="">Estado: Todos</option>
            <option value="pendiente">Pendiente</option>
            <option value="en_proceso">En proceso</option>
            <option value="resuelto">Resuelto</option>
          </select>
          {hayFiltros && (
            <button className="btn btn-ghost" onClick={limpiarFiltros} style={{ fontSize: '0.75rem', padding: '5px 10px' }}>
              Limpiar filtros
            </button>
          )}
          <button
            className="btn btn-outline"
            style={{ background: 'var(--color-purple-light)', borderColor: 'var(--color-purple)' }}
            onClick={refetch}
          >
            <span className="live-dot" style={{ width: 7, height: 7 }} />
            Actualizar datos en vivo
          </button>
        </div>
      </div>

      <div className="page-content">
        {/* Indicador de filtros activos */}
        {hayFiltros && (
          <div style={{ marginBottom: 12, padding: '7px 14px', background: 'var(--color-purple-light)', borderRadius: 'var(--radius-md)', fontSize: '0.75rem', color: 'var(--color-purple)', fontWeight: 600 }}>
            Mostrando {incidentesFiltrados.length} de {incidents?.length || 0} reportes — filtros activos
          </div>
        )}

        {/* Sub-tabs */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, flexWrap: 'wrap' }}>
          {TABS.map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              style={{
                padding: '6px 14px',
                borderRadius: '8px 8px 0 0',
                border: 'none',
                background:   activeTab === tab ? 'rgba(255, 218, 216, 0.2)' : 'transparent',
                borderBottom: activeTab === tab ? '2px solid var(--color-primary)' : '2px solid transparent',
                color:      activeTab === tab ? 'var(--color-primary)' : 'var(--color-text-main)',
                fontWeight: activeTab === tab ? 600 : 500,
                fontSize:   '0.75rem',
                cursor:     'pointer',
                transition: 'all 150ms ease',
                fontFamily: 'Inter, sans-serif',
              }}
            >{tab}</button>
          ))}
        </div>

        {/* KPI adicionales — siempre visibles */}
        {(activeTab === 'Resumen General' || activeTab === 'Tiempos SLA') && (
          <div className="kpi-grid">
            <MetricCard
              label="Tiempo medio resolución"
              value={m.promedioHrs != null ? `${m.promedioHrs} hrs` : '—'}
              badge={m.promedioHrs != null ? 'Calculado' : undefined}
              sub={
                m.resueltos > 0
                  ? `Basado en ${m.resueltos} incidente${m.resueltos > 1 ? 's' : ''} resuelto${m.resueltos > 1 ? 's' : ''}`
                  : 'Sin incidentes resueltos aún'
              }
              accentColor="var(--color-success)"
            />
            <MetricCard
              label="Cuadrante mayor frecuencia"
              value={m.topQuadrant}
              sub={
                m.topQuadrantCount > 0
                  ? `${m.topQuadrantPct}% del total — ${m.topQuadrantCount} reportes`
                  : 'Sin datos de cuadrantes aún'
              }
              accentColor="var(--color-primary-muted)"
            />
            <MetricCard
              label="Tasa de validación"
              value={`${m.tasaValidacion}%`}
              badge={m.tasaValidacion >= 80 ? 'En objetivo' : m.tasaValidacion > 0 ? 'En proceso' : undefined}
              sub={`${m.validados} de ${m.total} reportes validados`}
              accentColor="var(--color-navy)"
            />
            <MetricCard
              label="Incidentes validados"
              value={m.validados}
              sub={`${m.enProceso} en proceso · ${m.resueltos} resueltos`}
              accentColor="var(--color-success-mid)"
            />
          </div>
        )}

        {/* Contenido condicional por tab */}
        <div className="metrics-grid">

          {/* Donut por categoría */}
          {(activeTab === 'Resumen General' || activeTab === 'Por categoría') && (
            <div className="card col-4" style={{ overflow: 'hidden' }}>
              <div className="card-header">
                <div>
                  <div className="card-title">Reportes por Categoría</div>
                  <div className="card-subtitle">Distribución temática de incidencias</div>
                </div>
              </div>
              <div className="card-body">
                <div style={{ position: 'relative', display: 'flex', justifyContent: 'center', padding: '20px 0' }}>
                  <div style={{ width: 200, height: 200 }}>
                    {m.total > 0
                      ? <Doughnut data={donutData} options={donutOpts} />
                      : (
                        <div style={{ width: 200, height: 200, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--color-text-muted)', fontSize: '0.75rem' }}>
                          Sin datos
                        </div>
                      )
                    }
                  </div>
                  <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', textAlign: 'center', pointerEvents: 'none' }}>
                    <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1.75rem', color: 'var(--color-navy)' }}>
                      {m.total}
                    </div>
                    <div style={{ fontSize: '0.6875rem', fontWeight: 700, letterSpacing: '0.05em', textTransform: 'uppercase', color: 'var(--color-text-muted)' }}>
                      REPORTES
                    </div>
                  </div>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                  {Object.entries(m.byCategory).map(([cat, count]) => (
                    <div key={cat} className="legend-row">
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <div className="legend-dot" style={{ background: CATEGORY_COLOR[cat] }} />
                        <span className="legend-label">{CATEGORY_LABELS[cat]}</span>
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <span className="legend-count">{count}</span>
                        <span className="legend-pct">
                          {m.total > 0 ? Math.round(count / m.total * 100) : 0}%
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Bar por severidad */}
          {(activeTab === 'Resumen General' || activeTab === 'Por severidad') && (
            <div className="card col-4" style={{ overflow: 'hidden' }}>
              <div className="card-header">
                <div>
                  <div className="card-title">Distribución por Severidad</div>
                  <div className="card-subtitle">Urgencia de los reportes activos</div>
                </div>
              </div>
              <div className="card-body">
                <div style={{ height: 220 }}>
                  <Bar data={barData} options={barOpts} />
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 2, marginTop: 16 }}>
                  {Object.entries(m.bySeverity).map(([sev, count]) => (
                    <div key={sev} className="legend-row">
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <div className="legend-dot" style={{ background: SEVERITY_COLOR[sev] }} />
                        <span className="legend-label" style={{ textTransform: 'capitalize' }}>{sev}</span>
                      </div>
                      <span className="legend-count" style={{ fontWeight: 700 }}>{count}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Bar por cuadrante */}
          {(activeTab === 'Resumen General' || activeTab === 'Distribución Cuadrantes') && (
            <div className="card col-4" style={{ overflow: 'hidden' }}>
              <div className="card-header">
                <div>
                  <div className="card-title">Distribución por Cuadrante</div>
                  <div className="card-subtitle">Concentración territorial Q-01 a Q-14</div>
                </div>
              </div>
              <div className="card-body">
                {quadrantEntries.length > 0 ? (
                  <div style={{ height: 260 }}>
                    <Bar data={quadrantData} options={{ ...barOpts, indexAxis: 'y' }} />
                  </div>
                ) : (
                  <div className="empty-state">
                    <div className="empty-state-title">Sin datos de cuadrantes</div>
                    <div className="empty-state-sub">Los cuadrantes se asignan desde el panel de incidentes</div>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* SLA detail */}
          {activeTab === 'Tiempos SLA' && (
            <div className="card col-4" style={{ overflow: 'hidden', gridColumn: '1 / -1' }}>
              <div className="card-header">
                <div>
                  <div className="card-title">Detalle Tiempos SLA</div>
                  <div className="card-subtitle">Tiempo desde reporte hasta resolución</div>
                </div>
              </div>
              <div className="card-body">
                {m.promedioHrs != null ? (
                  <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap' }}>
                    <div>
                      <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Promedio general</div>
                      <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '2rem', color: 'var(--color-success)' }}>{m.promedioHrs} hrs</div>
                    </div>
                    <div>
                      <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Incidentes resueltos</div>
                      <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '2rem', color: 'var(--color-navy)' }}>{m.resueltos}</div>
                    </div>
                    <div>
                      <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>En proceso</div>
                      <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '2rem', color: 'var(--color-warning)' }}>{m.enProceso}</div>
                    </div>
                  </div>
                ) : (
                  <div className="empty-state">
                    <div className="empty-state-title">Sin incidentes resueltos</div>
                    <div className="empty-state-sub">Los tiempos SLA se calculan cuando existan reportes cerrados</div>
                  </div>
                )}
              </div>
            </div>
          )}

        </div>
      </div>
    </>
  );
}
